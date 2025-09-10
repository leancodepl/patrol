import { defineConfig } from "@playwright/test";

export default defineConfig({
  use: {
    // This needs to be dynamically injected with env variables
    baseURL: process.env.BASE_URL,
  },
  globalSetup: require.resolve("./tests/setup"),
  globalTeardown: require.resolve("./tests/teardown"),
});
