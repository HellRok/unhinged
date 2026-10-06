import { describe, it } from "node:test";
import assert from "node:assert/strict";
import esbuild from "esbuild";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { EventEmitter } from "node:events";
import { PassThrough } from "node:stream";
import { fileURLToPath } from "node:url";

import opalrbPlugin, {
  buildOpalArgs,
  formatOpalError,
  parseOpalError,
  runOpal,
} from "../lib/esbuild-plugin-opalrb.js";

const testDir = path.dirname(fileURLToPath(import.meta.url));
const fixture = (name) => path.join(testDir, "fixtures", name);

const brokenRb = fixture("broken.rb");
const validRb = fixture("valid.rb");
const requiresSampleRb = fixture("requires_sample.rb");
const syntaxErrorStderr = fs.readFileSync(
  fixture("opal-syntax-error.stderr.txt"),
  "utf8",
);

// Captures the handler the plugin registers so we can exercise it without
// spinning up esbuild for every assertion.
const loadFile = async (filepath, options = {}) => {
  let captured = null;
  opalrbPlugin(options).setup({
    onLoad: (config, handler) => {
      captured = { config, handler };
    },
  });
  if (!captured) throw new Error("plugin did not register an onLoad handler");
  return {
    filter: captured.config.filter,
    result: await captured.handler({ path: filepath }),
  };
};

// A child process we fully control, so failures can be tested without
// actually breaking anything.
const fakeSpawn =
  ({ code = 0, signal = null, stdout = "", stderr = "", spawnError = null }) =>
  () => {
    const child = new EventEmitter();
    child.stdout = new PassThrough();
    child.stderr = new PassThrough();

    process.nextTick(() => {
      if (spawnError) {
        child.emit("error", spawnError);
        child.emit("close", -2, null);
        return;
      }
      let pending = 2;
      const closed = () => {
        pending -= 1;
        if (pending === 0) child.emit("close", code, signal);
      };
      child.stdout.on("end", closed);
      child.stderr.on("end", closed);
      child.stdout.end(stdout);
      child.stderr.end(stderr);
    });

    return child;
  };

const standardArgv = (filepath) => [
  "exec",
  "opal",
  "--esm",
  "--compile",
  filepath,
];

describe("buildOpalArgs", () => {
  it("defaults to --esm and --compile", () => {
    assert.deepEqual(
      buildOpalArgs({ filepath: "app/app.rb" }),
      ["--esm", "--compile", "app/app.rb"],
      "both flags are present by default",
    );
  });

  it("esm: false drops only --esm", () => {
    assert.deepEqual(
      buildOpalArgs({ filepath: "app/app.rb", esm: false }),
      ["--compile", "app/app.rb"],
      "--compile is never optional",
    );
  });

  it("provideSourceMaps: false adds --no-source-map", () => {
    assert.deepEqual(
      buildOpalArgs({ filepath: "app/app.rb", provideSourceMaps: false }),
      ["--esm", "--compile", "--no-source-map", "app/app.rb"],
    );
    assert.ok(
      !buildOpalArgs({ filepath: "app/app.rb" }).includes("--no-source-map"),
      "source maps stay on by default",
    );
  });

  it("extraArgs follow the file path", () => {
    assert.deepEqual(
      buildOpalArgs({
        filepath: "app/app.rb",
        extraArgs: ["--include", "./app"],
      }),
      ["--esm", "--compile", "app/app.rb", "--include", "./app"],
    );
  });
});

describe("parseOpalError", () => {
  it("reads file, line, column and message", () => {
    const parsed = parseOpalError(syntaxErrorStderr);

    assert.equal(parsed.file, "test/fixtures/broken.rb");
    assert.equal(parsed.line, 4, "the failing line");
    assert.equal(parsed.column, 9, "opal's column 10 becomes esbuild's 9");
    assert.equal(parsed.message, "unterminated string meets end of file");
  });

  it("leaves bundler's backtrace out of the message", () => {
    const parsed = parseOpalError(syntaxErrorStderr);

    assert.ok(
      !JSON.stringify(parsed).includes("\tfrom "),
      "no ruby backtrace frames",
    );
    assert.ok(!JSON.stringify(parsed).includes("bundler"), "no bundler noise");
  });

  it("falls back to the ruby exception line", () => {
    const exceptionLine = syntaxErrorStderr
      .split("\n")
      .find((line) => line.includes(":in `"));
    const parsed = parseOpalError(exceptionLine);

    assert.equal(parsed.line, 4, "still finds the line");
    assert.equal(parsed.column, 0, "no column available, starts at zero");
    assert.ok(
      parsed.message.includes("Opal::SyntaxError"),
      `got "${parsed.message}"`,
    );
  });

  it("returns null when there is no location to find", () => {
    assert.equal(
      parseOpalError("bundler: failed to load command: opal (/usr/bin/opal)\n"),
      null,
    );
    assert.equal(parseOpalError(""), null, "empty stderr is not an error");
  });
});

describe("formatOpalError", () => {
  it("builds an esbuild error with a code frame location", async () => {
    const error = await formatOpalError({
      filepath: brokenRb,
      argv: standardArgv(brokenRb),
      code: 1,
      stderr: syntaxErrorStderr,
    });

    assert.equal(error.text, "unterminated string meets end of file");
    assert.equal(error.location.line, 4);
    assert.equal(error.location.column, 9);
    assert.equal(
      error.location.lineText,
      '    puts "Hello',
      "reads the failing line from disk for esbuild's code frame",
    );
    assert.ok(error.location.file.endsWith("broken.rb"));
    assert.match(
      error.notes[0].text,
      /Opal exited with code 1\. Command: bundle exec opal --esm --compile/,
      "the command is copy-pasteable",
    );
    assert.ok(
      error.notes.some((note) => note.text.includes("Opal::SyntaxError")),
      "keeps the ruby exception as a note",
    );
    assert.ok(
      !JSON.stringify(error).includes("\tfrom "),
      "the backtrace is dropped",
    );
  });

  it("summarises stderr when there is no location", async () => {
    const error = await formatOpalError({
      filepath: brokenRb,
      argv: standardArgv(brokenRb),
      code: 1,
      stderr: "bundler: failed to load command: opal (/usr/bin/opal)\n",
    });

    assert.equal(error.location, undefined, "no fake location");
    assert.match(error.text, /^Opal failed to compile /);
    assert.ok(error.text.includes(brokenRb), "names the file");
    assert.ok(
      error.text.includes("bundler: failed to load command"),
      "keeps the useful stderr line",
    );
    assert.match(error.notes[0].text, /bundle exec opal/);
  });

  it("names the signal when opal is killed", async () => {
    const error = await formatOpalError({
      filepath: brokenRb,
      argv: standardArgv(brokenRb),
      signal: "SIGKILL",
      stderr: "",
    });

    assert.match(error.notes[0].text, /killed by SIGKILL/);
  });
});

describe("runOpal", () => {
  it("collects stdout and stderr on success", async () => {
    const result = await runOpal(["exec", "opal"], {
      spawnImpl: fakeSpawn({ stdout: "compiled js", stderr: "a warning" }),
    });

    assert.equal(result.code, 0);
    assert.equal(result.signal, null);
    assert.equal(result.spawnError, null);
    assert.equal(result.stdout, "compiled js");
    assert.equal(result.stderr, "a warning");
  });

  it("reports a non-zero exit without throwing", async () => {
    const result = await runOpal(["exec", "opal"], {
      spawnImpl: fakeSpawn({ code: 1, stderr: "boom" }),
    });

    assert.equal(result.code, 1);
    assert.equal(result.stderr, "boom");
  });

  it("reports the signal when the process is killed", async () => {
    const result = await runOpal(["exec", "opal"], {
      spawnImpl: fakeSpawn({ code: null, signal: "SIGKILL" }),
    });

    assert.equal(result.signal, "SIGKILL");
    assert.equal(result.code, null);
  });

  it("reports a missing binary instead of crashing", async () => {
    const result = await runOpal(["exec", "opal"], {
      command: "unhinged-binary-that-does-not-exist",
    });

    assert.equal(result.spawnError?.code, "ENOENT");
  });

  it(
    "drains stdout and stderr at the same time",
    { timeout: 20000 },
    async () => {
      const size = 1024 * 1024;
      const script = `process.stderr.write("e".repeat(${size})); process.stdout.write("o".repeat(${size}));`;

      const result = await runOpal(["-e", script], { command: "node" });

      assert.equal(
        result.code,
        0,
        "the child was never blocked on a full pipe",
      );
      assert.equal(result.stderr.length, size, "all of stderr arrived");
      assert.equal(result.stdout.length, size, "all of stdout arrived");
    },
  );
});

describe("opalrbPlugin", () => {
  it("registers an onLoad handler for .rb files", () => {
    let captured = null;
    opalrbPlugin().setup({
      onLoad: (config) => {
        captured = config;
      },
    });

    assert.ok(captured, "a handler was registered");
    assert.ok(captured.filter.test("app/app.rb"), "matches .rb");
    assert.ok(!captured.filter.test("app/app.js"), "ignores .js");
  });

  it("explains a missing bundle instead of crashing", async () => {
    const originalPath = process.env.PATH;
    process.env.PATH = "/unhinged-nowhere";

    try {
      const { result } = await loadFile(validRb);
      const [error] = result.errors ?? [];

      assert.ok(error, "returned an esbuild error");
      assert.match(error.text, /`bundle` could not be found/);
      assert.match(error.text, /bundle install/);
      assert.match(error.notes[0].text, /Command: bundle exec opal/);
    } finally {
      process.env.PATH = originalPath;
    }
  });

  it("does not mutate the options it was given", () => {
    const options = { extraArgs: ["--include", "./app"] };
    opalrbPlugin(options).setup({ onLoad: () => {} });

    assert.deepEqual(options, { extraArgs: ["--include", "./app"] });
    assert.equal(options.esm, undefined, "no esm default written back");
    assert.equal(
      options.buildFilter,
      undefined,
      "no buildFilter default written back",
    );
  });
});

// Everything below needs a working `bundle exec opal`, so it skips itself
// rather than failing for anyone who has not installed the gems.
const opalAvailable = await runOpal(["exec", "opal", "--version"]).then(
  (result) => !result.spawnError && result.code === 0,
);
const withoutOpal = opalAvailable
  ? false
  : "`bundle exec opal` is not available";

describe("opalrbPlugin with opal", () => {
  it("compiles a .rb file into JavaScript", { skip: withoutOpal }, async () => {
    const { filter, result } = await loadFile(validRb);

    assert.ok(filter.test(validRb), "the default filter matches .rb files");
    assert.equal(result.errors, undefined, "no errors");
    assert.equal(result.loader, "js");
    assert.ok(result.contents.includes("export default"), "esm by default");
    assert.ok(result.contents.length > 1000, "opal's output arrived");
  });

  it(
    "points at the exact line that failed",
    { skip: withoutOpal },
    async () => {
      const { result } = await loadFile(brokenRb);
      const [error] = result.errors ?? [];

      assert.ok(error, "returned an esbuild error");
      assert.equal(error.text, "unterminated string meets end of file");
      assert.equal(error.location.line, 4, "line 4 of the fixture");
      assert.equal(error.location.column, 9, "column 10, zero based");
      assert.equal(error.location.lineText, '    puts "Hello');
      assert.ok(error.location.file.endsWith("broken.rb"));
    },
  );

  it(
    "esbuild renders the failing line in the build failure",
    { skip: withoutOpal },
    async () => {
      try {
        await esbuild.build({
          entryPoints: [brokenRb],
          bundle: true,
          write: false,
          logLevel: "silent",
          plugins: [opalrbPlugin()],
        });
        assert.fail("the build should have failed");
      } catch (error) {
        const [failure] = error.errors ?? [];

        assert.ok(failure, "esbuild reported the error");
        assert.match(failure.text, /unterminated string/);
        assert.equal(failure.location.line, 4);
        assert.equal(failure.location.lineText, '    puts "Hello');
      }
    },
  );

  it(
    "esm and source map options reach the command line",
    { skip: withoutOpal },
    async () => {
      const defaults = await loadFile(brokenRb);
      const defaultCommand = defaults.result.errors[0].notes[0].text;
      assert.match(defaultCommand, /--esm/);
      assert.doesNotMatch(defaultCommand, /--no-source-map/);

      const custom = await loadFile(brokenRb, {
        esm: false,
        provideSourceMaps: false,
        extraArgs: ["--include", "test/fixtures"],
      });
      const customCommand = custom.result.errors[0].notes[0].text;
      assert.doesNotMatch(customCommand, /--esm/);
      assert.match(customCommand, /--no-source-map/);
      assert.match(customCommand, /--include test\/fixtures/);
    },
  );

  it(
    "warns when opal writes nothing to stdout",
    { skip: withoutOpal },
    async () => {
      const outputPath = path.join(
        os.tmpdir(),
        `unhinged-opal-${process.pid}.js`,
      );

      try {
        const { result } = await loadFile(validRb, {
          extraArgs: ["--output", outputPath],
        });

        assert.equal(result.errors, undefined, "it is a warning, not an error");
        assert.equal(result.warnings?.length, 1);
        assert.match(result.warnings[0].text, /wrote no JavaScript/);
        assert.match(result.warnings[0].notes[0].text, /--output/);
      } finally {
        await fs.promises.rm(outputPath, { force: true });
      }
    },
  );

  it(
    "finds a required file through the include path",
    { skip: withoutOpal },
    async () => {
      const { result } = await loadFile(requiresSampleRb, {
        extraArgs: ["--include", "test/fixtures"],
      });
      const [error] = result.errors ?? [];

      assert.ok(error, "the error came from the required file");
      assert.equal(error.location.line, 3, "line 3 of components/sample.rb");
      assert.equal(
        error.location.lineText,
        '    puts "oops',
        "resolved the file through --include to get its contents",
      );
      assert.ok(
        error.location.file.endsWith(
          path.join("test", "fixtures", "components", "sample.rb"),
        ),
        `resolved to ${error.location.file}`,
      );
      assert.ok(path.isAbsolute(error.location.file));
    },
  );
});
