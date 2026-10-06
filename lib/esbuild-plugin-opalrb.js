import { spawn } from "child_process";
import fs from "fs/promises";
import path from "path";

const DEFAULT_COMMAND = "bundle";
const DEFAULT_BUILD_FILTER = /\.rb$/;

// e.g. "app/app.rb:4:10: fatal: unterminated string meets end of file"
const DIAGNOSTIC_PATTERN =
  /^(.+?):(\d+):(?:(\d+):)?\s*(?:error|fatal|warning):\s*(.+)$/;
// e.g. "app/app.rb:4:in `    puts \"Hello': unexpected token (Opal::SyntaxError)"
const RUBY_EXCEPTION_PATTERN = /^(.+?):(\d+):in\s+(.+?):\s+(.+)$/;

export const buildOpalArgs = ({
  filepath,
  esm = true,
  provideSourceMaps = true,
  extraArgs = [],
}) => {
  const args = [];
  if (esm) args.push("--esm");
  args.push("--compile");
  if (!provideSourceMaps) args.push("--no-source-map");
  args.push(filepath);
  args.push(...extraArgs);
  return args;
};

export const formatCommand = (argv, command = DEFAULT_COMMAND) =>
  [command, ...argv]
    .map((arg) => (/\s/.test(arg) ? JSON.stringify(arg) : arg))
    .join(" ");

// Runs opal and resolves with everything we need to explain a failure.
// Never rejects: a missing binary shows up as `spawnError`.
export const runOpal = (
  argv,
  { command = DEFAULT_COMMAND, spawnImpl = spawn } = {},
) =>
  new Promise((resolve) => {
    const result = {
      code: null,
      signal: null,
      stdout: "",
      stderr: "",
      spawnError: null,
    };
    let settled = false;
    const settle = () => {
      if (!settled) {
        settled = true;
        resolve(result);
      }
    };

    let child;
    try {
      child = spawnImpl(command, argv, { stdio: ["ignore", "pipe", "pipe"] });
    } catch (error) {
      result.spawnError = error;
      settle();
      return;
    }

    // Drain both streams at the same time: opal can write megabytes of
    // output while also dumping a large backtrace to stderr, and reading
    // them one after the other can deadlock on a full pipe buffer.
    if (child.stdout) {
      child.stdout.setEncoding("utf8");
      child.stdout.on("data", (chunk) => {
        result.stdout += chunk;
      });
    }
    if (child.stderr) {
      child.stderr.setEncoding("utf8");
      child.stderr.on("data", (chunk) => {
        result.stderr += chunk;
      });
    }

    child.on("error", (error) => {
      result.spawnError = error;
      settle();
    });
    child.on("close", (code, signal) => {
      result.code = code;
      result.signal = signal;
      settle();
    });
  });

export const parseOpalError = (stderr) => {
  const lines = String(stderr ?? "").split(/\r?\n/);

  const diagnostic = lines
    .map((line) => line.match(DIAGNOSTIC_PATTERN))
    .find(Boolean);
  if (diagnostic) {
    return {
      file: diagnostic[1],
      line: Number(diagnostic[2]),
      // Opal reports 1-based columns, esbuild wants 0-based ones.
      column: diagnostic[3] ? Number(diagnostic[3]) - 1 : 0,
      message: diagnostic[4].trim(),
    };
  }

  const exception = lines
    .map((line) => line.match(RUBY_EXCEPTION_PATTERN))
    .find(Boolean);
  if (exception) {
    return {
      file: exception[1],
      line: Number(exception[2]),
      column: 0,
      message: exception[4].trim(),
    };
  }

  return null;
};

// Opal names required files relative to the -I/--include directories rather
// than to the working directory, so search those before giving up on a file.
const includeDirs = (extraArgs) => {
  const dirs = [];
  for (let i = 0; i < extraArgs.length; i += 1) {
    const arg = extraArgs[i];
    if (arg === "-I" || arg === "--include") {
      dirs.push(extraArgs[i + 1]);
      i += 1;
    } else if (arg.startsWith("--include=")) {
      dirs.push(arg.slice("--include=".length));
    } else if (arg.startsWith("-I") && arg.length > 2) {
      dirs.push(arg.slice(2));
    }
  }
  return dirs.filter(Boolean);
};

const resolveReportedFile = async (reported, extraArgs) => {
  const candidates = [
    reported,
    ...includeDirs(extraArgs).map((dir) => path.resolve(dir, reported)),
  ];
  for (const candidate of candidates) {
    try {
      await fs.access(candidate);
      return path.resolve(candidate);
    } catch {
      // keep looking
    }
  }
  return reported;
};

const lineTextAt = async (file, line) => {
  try {
    const source = await fs.readFile(file, "utf8");
    return source.split(/\r?\n/)[line - 1] ?? "";
  } catch {
    return "";
  }
};

const summariseStderr = (stderr) =>
  String(stderr ?? "")
    .split(/\r?\n/)
    .filter((line) => line.trim() && !line.startsWith("\tfrom "))
    .slice(0, 8)
    .join("\n");

export const formatOpalError = async ({
  filepath,
  argv = [],
  extraArgs = [],
  command = DEFAULT_COMMAND,
  code = null,
  signal = null,
  stderr = "",
}) => {
  const commandLine = formatCommand(argv, command);
  const parsed = parseOpalError(stderr);
  const rubyException = String(stderr ?? "")
    .split(/\r?\n/)
    .map((line) => line.match(RUBY_EXCEPTION_PATTERN))
    .find(Boolean);

  const notes = [
    {
      text: signal
        ? `Opal was killed by ${signal}. Command: ${commandLine}`
        : `Opal exited with code ${code}. Command: ${commandLine}`,
    },
  ];
  if (rubyException && rubyException[4] !== parsed?.message) {
    notes.push({ text: rubyException[0].trim() });
  }

  if (parsed) {
    const file = await resolveReportedFile(parsed.file || filepath, extraArgs);
    return {
      text: parsed.message,
      notes,
      location: {
        file,
        namespace: "file",
        line: parsed.line,
        column: parsed.column,
        lineText: await lineTextAt(file, parsed.line),
      },
    };
  }

  const detail = summariseStderr(stderr);
  return {
    text: `Opal failed to compile ${filepath}${detail ? `:\n${detail}` : ""}`,
    notes,
  };
};

const opalrbPlugin = (options = {}) => ({
  name: "opalrb",
  setup(build) {
    const buildFilter = options.buildFilter ?? DEFAULT_BUILD_FILTER;
    const esm = options.esm !== false;
    const provideSourceMaps = options.provideSourceMaps !== false;
    const extraArgs = Array.isArray(options.extraArgs)
      ? [...options.extraArgs]
      : [];

    build.onLoad({ filter: buildFilter }, async (args) => {
      const opalArgs = buildOpalArgs({
        filepath: args.path,
        esm,
        provideSourceMaps,
        extraArgs,
      });
      // buildOpalArgs returns opal's own arguments, so prefix the bundle exec.
      const argv = ["exec", "opal", ...opalArgs];
      const commandLine = formatCommand(argv);
      const { code, signal, stdout, stderr, spawnError } = await runOpal(argv);

      if (spawnError) {
        return {
          errors: [
            {
              text:
                spawnError.code === "ENOENT"
                  ? `\`${DEFAULT_COMMAND}\` could not be found. Is Ruby installed, and have you run \`bundle install\`?`
                  : `Could not start Opal: ${spawnError.message}`,
              notes: [{ text: `Command: ${commandLine}` }],
            },
          ],
        };
      }

      if (code !== 0 || signal) {
        return {
          errors: [
            await formatOpalError({
              filepath: args.path,
              argv,
              extraArgs,
              code,
              signal,
              stderr,
            }),
          ],
        };
      }

      if (!stdout.trim()) {
        return {
          warnings: [
            {
              text: `Opal compiled ${args.path} but wrote no JavaScript to stdout.`,
              notes: [{ text: `Command: ${commandLine}` }],
            },
          ],
        };
      }

      return { contents: stdout, loader: "js" };
    });
  },
});

export default opalrbPlugin;
