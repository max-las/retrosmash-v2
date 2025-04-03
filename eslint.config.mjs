import { defineConfig } from "eslint/config";
import globals from "globals";
import stylisticJs from '@stylistic/eslint-plugin-js';


export default defineConfig([
  {
    files: [
      "frontend/javascript/controllers/**/*.js",
      "frontend/javascript/models/**/*.js",
      "frontend/javascript/db.js"
    ],
    languageOptions: { globals: globals.browser },
    plugins: {
      '@stylistic/js': stylisticJs
    },
    rules: {
      '@stylistic/js/semi': ['error', 'always']
    }
  },
]);
