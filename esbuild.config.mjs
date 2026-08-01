import esbuild from "esbuild";
import fs from "node:fs";
import path from "node:path";
import opalrbPlugin from "./lib/esbuild-plugin-opalrb.js";

const workspace = process.cwd();
const environment = process.env.NODE_ENV;
const is_production = environment == "production";

const options = {
  bundle: true,
  format: "iife",
  minify: is_production,
  sourcemap: !is_production,
  loader: {
    ".css": "css",
    ".html": "copy",
  },
  logLevel: "info",
  entryNames: "[name]",
  assetNames: "assets/[name]-[hash]",
  define: {
    "process.env.NODE_ENV": `"${environment}"`,
  },
  external: ["node_modules/*"],
  plugins: [
    opalrbPlugin({ extraArgs: [
      "--include", "./app",
    ] }),
  ],
  metafile: true,
};

if (process.argv.indexOf("--serve") >= 0) {
  esbuild.context({
    entryPoints: ["app/app.rb", "app/index.html"],
    outdir: "dist",
    inject: ["lib/live-reload.js"],
    ...options,
  }).then(async (context) => {
    await context.watch();
    await context.serve({ servedir: "dist" })
  });

} else {
  esbuild
    .build({
      entryPoints: ["app/app.rb", "app/index.html"],
      outdir: "dist",
      ...options,
    })
    .then((result) => {
      fs.writeFileSync(
        path.join(workspace, "./meta.json"),
        JSON.stringify(result.metafile),
      );
      console.log("Assets built!");
    })
    .catch((e) => {
      console.error("=== KABOOM! ===");
      console.error(e);
      process.exit(1);
    });
}
