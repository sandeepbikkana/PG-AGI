// import { test, expect } from "@playwright/test";

// test("page loads", async ({ page }) => {
//   await page.goto("http://localhost:3000");
//   await expect(page.locator("h1")).toHaveText("DevOps Assignment");
// });

// test("backend message is displayed", async ({ page }) => {
//   await page.goto("http://localhost:3000");

//   const message = page.locator('[data-testid="message"]');

//   await expect(message).toBeVisible();
//   await expect(message).not.toHaveText("Loading...");
// });




import { test, expect } from "@playwright/test";

test("page loads", async ({ page }) => {
  await page.goto("http://localhost:3000");

  await expect(page.locator("h1")).toHaveText("DevOps Assignment");
});

test("backend message is displayed", async ({ page }) => {
  await page.goto("http://localhost:3000");

  // ✅ Wait until element exists in DOM
  await page.waitForSelector('[data-testid="message"]', {
    timeout: 10000
  });

  const message = page.locator('[data-testid="message"]');

  // ✅ Wait until backend replaces Loading...
  await expect(message).not.toHaveText("Loading...", {
    timeout: 10000
  });

  // Optional stronger validation
  await expect(message).toHaveText(/.+/);
});
