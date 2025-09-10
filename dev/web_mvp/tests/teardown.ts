import fs from "fs/promises";
import path from "path";

async function globalTeardown() {
  await fs.unlink(path.join(__dirname, "tests.json"));
}

export default globalTeardown;
