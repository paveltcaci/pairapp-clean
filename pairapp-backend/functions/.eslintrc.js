module.exports = {
  root: true,
  env: {
    es2021: true,
    node: true,
  },
  extends: [
    "eslint:recommended",
    "google",
    "plugin:@typescript-eslint/recommended",
  ],
  parser: "@typescript-eslint/parser",
  parserOptions: {
    project: ["tsconfig.json"],
    sourceType: "module",
  },
  ignorePatterns: ["/lib/**/*", "/node_modules/**/*"],
  plugins: ["@typescript-eslint", "import"],
  rules: {
    "quotes": ["error", "double"],
    "import/no-unresolved": "off",
    "require-jsdoc": "off",
    "valid-jsdoc": "off",
    "max-len": ["warn", { code: 120 }],
    "object-curly-spacing": ["error", "always"],
    "indent": "off",
    "@typescript-eslint/no-unused-vars": ["warn"],
  },
};
