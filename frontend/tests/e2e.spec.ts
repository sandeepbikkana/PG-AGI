import { test, expect } from "@playwright/test";

test("page loads", async ({ page }) => {
  await page.goto("http://localhost:3000");
  await expect(page.locator("h1")).toHaveText("DevOps Assignment");
});

test("backend message is displayed", async ({ page }) => {
  // ✅ Mock backend BEFORE navigation
  await page.route("**/api/health", route =>
    route.fulfill({
      status: 200,
      contentType: "application/json",
      body: JSON.stringify({ status: "healthy" })
    })
  );

  await page.route("**/api/message", route =>
    route.fulfill({
      status: 200,
      contentType: "application/json",
      body: JSON.stringify({ message: "Hello from backend" })
    })
  );

  await page.goto("http://localhost:3000");

  const message = page.locator('[data-testid="message"]');

  await expect(message).toHaveText("Hello from backend", {
    timeout: 10000
  });
});
