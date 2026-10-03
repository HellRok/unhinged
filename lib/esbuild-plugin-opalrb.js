import fs from "fs/promises";
import { spawn } from "child_process";

const spawnChild = async (source, extraArgs, filepath) => {
  const child = spawn("bundle", [
    "exec",
    "opal",
    "--esm",
    "--compile",
    filepath,
    ...extraArgs,
  ]);

  child.stdin.write(source);
  child.stdin.end();

  let data = "";
  for await (const chunk of child.stdout) {
    data += chunk;
  }
  let error = "";
  for await (const chunk of child.stderr) {
    error += chunk;
  }
  const exitCode = await new Promise((resolve, reject) => {
    child.on("close", resolve);
  });

  if (exitCode) {
    throw new Error(`subprocess error exit ${exitCode}, ${data} ${error}`);
  }
  return data;
};

const opalrbPlugin = (options = {}) => ({
  name: "opalrb",
  setup(build) {
    if (!options.buildFilter) options.buildFilter = /\.rb$/;
    let extraArgs = [];
    if (typeof options.provideSourceMaps === "undefined") {
      options.provideSourceMaps = true;
    }
    if (!options.provideSourceMaps) {
      extraArgs.push("--no-source-map");
    }
    if (typeof options.extraArgs !== undefined) {
      extraArgs = [...extraArgs, ...(options.extraArgs || [])];
    }

    build.onLoad({ filter: options.buildFilter }, async (args) => {
      const code = await fs.readFile(args.path, "utf8");
      let js = await spawnChild(code, extraArgs, args.path);

      return {
        contents: js,
        loader: "js",
      };
    });
  },
});

export default opalrbPlugin;
