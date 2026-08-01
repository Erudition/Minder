import { chromium } from 'playwright';
import fs from 'fs';
import path from 'path';
import http from 'http';
import { spawn } from 'child_process';

let browser = null;
let serverProcess = null;

const globalTimeout = setTimeout(() => {
  console.error('GLOBAL TIMEOUT: crosstab-sync test took longer than 60s, terminating.');
  cleanup();
  process.exit(1);
}, 60000);

function cleanup() {
  clearTimeout(globalTimeout);
  if (browser) {
    browser.close().catch(() => {});
    browser = null;
  }
  if (serverProcess) {
    try {
      if (serverProcess.pid) {
        try {
          process.kill(-serverProcess.pid, 'SIGKILL');
        } catch (e) {
          serverProcess.kill('SIGKILL');
        }
      }
    } catch (e) {}
    serverProcess = null;
  }
}

process.on('uncaughtException', (err) => {
  console.error('Uncaught exception:', err);
  cleanup();
  process.exit(1);
});

process.on('unhandledRejection', (err) => {
  console.error('Unhandled rejection:', err);
  cleanup();
  process.exit(1);
});

process.on('SIGINT', () => {
  cleanup();
  process.exit(1);
});

process.on('SIGTERM', () => {
  cleanup();
  process.exit(1);
});

process.on('exit', () => cleanup());

const checkServer = (url) => new Promise((resolve) => {
  http.get(url, (res) => resolve(res.statusCode === 200)).on('error', () => resolve(false));
});

(async () => {
  console.log('Starting Playwright cross-tab sync test...');
  const targetUrl = 'http://localhost:4173/';

  let isUp = await checkServer(targetUrl);
  if (!isUp) {
    console.log('Preview server on :4173 not running, starting it...');
    serverProcess = spawn('pnpm', ['exec', 'vite', 'preview', '--port', '4173', '--host'], {
      stdio: 'ignore',
      detached: true,
    });
    for (let i = 0; i < 30; i++) {
      await new Promise(r => setTimeout(r, 1000));
      isUp = await checkServer(targetUrl);
      if (isUp) break;
    }
    if (!isUp) {
      console.error('Failed to start preview server.');
      cleanup();
      process.exit(1);
    }
  }

  browser = await chromium.launch({
    headless: false,
    executablePath: '/home/adroit/.guix-profile/bin/chromium',
  });

  const context = await browser.newContext();

  try {
    context.on('serviceworker', sw => {
      console.log('SW CREATED:', sw.url());
      sw.on('console', msg => console.log('SW LOG:', msg.type(), msg.text()));
    });
  } catch (err) {
    console.warn('ServiceWorker connection/listener error (handled gracefully):', err);
  }

  const pageA = await context.newPage();
  const pageB = await context.newPage();

  pageA.setDefaultTimeout(10000);
  pageB.setDefaultTimeout(10000);

  pageA.on('console', msg => console.log('PAGE A:', msg.type(), msg.text()));
  pageB.on('console', msg => console.log('PAGE B:', msg.type(), msg.text()));
  pageA.on('pageerror', err => console.error('PAGE A ERROR:', err));
  pageB.on('pageerror', err => console.error('PAGE B ERROR:', err));
  
  console.log('Navigating both tabs to target URL...');
  await pageA.goto(targetUrl, { timeout: 10000 }).catch(err => console.warn('pageA goto failed:', err));
  await pageB.goto(targetUrl, { timeout: 10000 }).catch(err => console.warn('pageB goto failed:', err));

  console.log('Waiting for splash screens to disappear...');
  try {
    await pageA.waitForSelector('#load-info', { state: 'hidden', timeout: 10000 });
    await pageB.waitForSelector('#load-info', { state: 'hidden', timeout: 10000 });
  } catch (e) {
    console.log('Timeout waiting for #load-info hidden (might have been removed or JS error), proceeding anyway...');
  }

  console.log('Navigating to Projects view...');
  await pageA.goto(targetUrl + '#/task-list', { timeout: 10000 });
  await pageB.goto(targetUrl + '#/task-list', { timeout: 10000 });
  
  // Wait a bit for Elm to fully render
  await pageA.waitForTimeout(3000);
  await pageB.waitForTimeout(3000);

  const testProjectName = `CrossTab Test ${Date.now()}`;
  console.log(`Creating project "${testProjectName}" in Tab A...`);

  // Fill in the project name and submit
  // Try to find the correct input element
  const inputA = pageA.locator('ion-input').first();
  await inputA.waitFor({ state: 'visible', timeout: 10000 });
  await inputA.evaluate((el, value) => {
    el.value = value;
    el.dispatchEvent(new Event('input', { bubbles: true }));
    el.dispatchEvent(new CustomEvent('ionInput', { bubbles: true, detail: { value } }));
    el.dispatchEvent(new Event('change', { bubbles: true }));
  }, testProjectName);
  await inputA.press('Enter');

  console.log('Waiting for project to appear in Tab B (cross-tab sync)...');
  
  // Poll Tab B's DOM for the new project name
  let syncSuccess = false;
  for (let i = 0; i < 20; i++) {
    const text = await pageB.evaluate(() => document.body.innerText).catch(() => '');
    if (text.includes(testProjectName)) {
      syncSuccess = true;
      break;
    }
    await pageB.waitForTimeout(500); // Check every 500ms
  }

  if (syncSuccess) {
    console.log('SUCCESS: Cross-tab sync verified in live DOM!');
    await pageA.screenshot({ path: '/tmp/playwright-qa/task-6-tabA.png' }).catch(() => {});
    await pageB.screenshot({ path: '/tmp/playwright-qa/task-6-tabB.png' }).catch(() => {});
  } else {
    console.error('FAILED: Cross-tab sync did not occur within timeout.');
    await pageA.screenshot({ path: '/tmp/playwright-qa/task-6-tabA-fail.png' }).catch(() => {});
    await pageB.screenshot({ path: '/tmp/playwright-qa/task-6-tabB-fail.png' }).catch(() => {});
    cleanup();
    process.exit(1);
  }

  console.log('Reloading both tabs to verify persistence...');
  await pageA.reload({ timeout: 10000 }).catch(err => console.warn('pageA reload warning:', err));
  await pageB.reload({ timeout: 10000 }).catch(err => console.warn('pageB reload warning:', err));

  let persistenceSuccess = false;
  for (let i = 0; i < 20; i++) {
    const textAReloaded = await pageA.evaluate(() => document.body.innerText).catch(() => '');
    const textBReloaded = await pageB.evaluate(() => document.body.innerText).catch(() => '');
    console.log(`RELOAD CHECK ${i}: A URL: ${pageA.url()}, A text includes project? ${textAReloaded.includes(testProjectName)}, B text includes project? ${textBReloaded.includes(testProjectName)}`);
    if (textAReloaded.includes(testProjectName) && textBReloaded.includes(testProjectName)) {
      persistenceSuccess = true;
      break;
    }
    await pageA.waitForTimeout(500);
  }

  if (persistenceSuccess) {
    console.log('SUCCESS: Persistence verified after reload!');
    await pageA.screenshot({ path: '/tmp/playwright-qa/task-6-reloaded.png' }).catch(() => {});
  } else {
    console.error('FAILED: Persistence failed after reload.');
    cleanup();
    process.exit(1);
  }

  console.log('All checks passed.');
  cleanup();
  process.exit(0);
})();
