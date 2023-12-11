import resolve from "@rollup/plugin-node-resolve"
import terser from "@rollup/plugin-terser"

export default [
  {
    input: "navigation/application.js",
    output: [
      {
        name: "navigation",
        file: "app/assets/builds/katalyst/navigation.esm.js",
        format: "esm",
      },
      {
        file: "app/assets/builds/katalyst/navigation.js",
        format: "es",
      },
    ],
    context: "window",
    plugins: [
      resolve({
        modulePaths: ["app/javascript"]
      })
    ],
    external: ["@hotwired/stimulus", "@hotwired/turbo-rails"]
  },
  {
    input: "navigation/application.js",
    output: {
      file: "app/assets/builds/katalyst/navigation.min.js",
      format: "es",
      sourcemap: true,
    },
    context: "window",
    plugins: [
      resolve({
        modulePaths: ["app/javascript"]
      }),
      terser({
        mangle: true,
        compress: true
      })
    ],
    external: ["@hotwired/stimulus", "@hotwired/turbo-rails"]
  }
]
