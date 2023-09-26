import { resolve } from "path";
import { nodeResolve } from "@rollup/plugin-node-resolve";
import { defineConfig } from "vite";
//TODO: push this change and depend on it in overlay
import react from "/Users/josephprice/dev/vite-plugin-react-swc/src/index.ts";

export default defineConfig({
  server: {
    watch: {
      ignored: [
        "**/_build/**",
        "**/**/*.re",
        "!**/_build/default/ui/js/main/**/*.js",
      ],
    },
  },
  build: {
    manifest: true,
    output: {
      app: "app.js",
    },
    rollupOptions: {
      input: {
        app: resolve(__dirname, "_build/default/ui/js/main/ui/js/main.js"),
        styles: resolve(__dirname, "ui/input.css"),
      },
    },
    outDir: "static",
  },
  plugins: [
    nodeResolve(),
    react({
      include: /\.js$/,
    }),
    {
      plugin: "vite:hmr-logger",
      handleHotUpdate({ file, server }) {
        if (file.endsWith(".processes/server-start.txt")) {
          console.log("full page reload", file);
          server.ws.send({ type: "full-reload" });
          return [];
        } else {
          console.log("file changed", file);
        }
      },
    },
  ],
});
