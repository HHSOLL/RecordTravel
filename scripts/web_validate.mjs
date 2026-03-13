#!/usr/bin/env node

const browserName = process.argv[2];
const url = process.argv[3];
const settleMs = Number(process.argv[4] ?? 7000);

if (!browserName || !url) {
  console.error('Usage: node scripts/web_validate.mjs <browser> <url> [settleMs]');
  process.exit(1);
}

const playwright = await import('playwright');

async function launch() {
  switch (browserName) {
    case 'chrome':
      return playwright.chromium.launch({ channel: 'chrome', headless: true });
    case 'edge':
      return playwright.chromium.launch({ channel: 'msedge', headless: true });
    case 'firefox':
      return playwright.firefox.launch({ headless: true });
    default:
      throw new Error(`Unsupported browser: ${browserName}`);
  }
}

function parseTaggedJson(messages, tag) {
  const prefix = `${tag}|`;
  for (const entry of messages) {
    const line = entry.text;
    const index = line.indexOf(prefix);
    if (index == -1) {
      continue;
    }
    const payload = line.slice(index + prefix.length);
    try {
      return JSON.parse(payload);
    } catch (_) {
      return { parseError: true, raw: payload };
    }
  }
  return null;
}

const browser = await launch();
const page = await browser.newPage({ viewport: { width: 1440, height: 960 } });

const consoleMessages = [];
page.on('console', (message) => {
  consoleMessages.push({
    type: message.type(),
    text: message.text(),
  });
});

const pageErrors = [];
page.on('pageerror', (error) => {
  pageErrors.push(String(error));
});

let gotoOk = false;
let gotoError = null;
try {
  await page.goto(url, { waitUntil: 'networkidle', timeout: 30000 });
  gotoOk = true;
} catch (error) {
  gotoError = String(error);
}

if (gotoOk) {
  const viewport = page.viewportSize();
  if (viewport) {
    const centerX = Math.floor(viewport.width / 2);
    const centerY = Math.floor(viewport.height / 2);
    await page.mouse.move(centerX, centerY);
    await page.mouse.down();
    await page.mouse.move(centerX + 120, centerY - 40, { steps: 12 });
    await page.mouse.up();
    await page.mouse.wheel(0, 280);
    await page.mouse.click(centerX, centerY);
  }
  await page.waitForTimeout(settleMs);
}

const domInfo = gotoOk
  ? await page.evaluate(() => ({
      title: document.title,
      canvasCount: document.querySelectorAll('canvas').length,
      flutterViewCount: document.querySelectorAll('flutter-view').length,
      fltGlassPaneCount: document.querySelectorAll('flt-glass-pane').length,
      bodyTextLength: (document.body?.innerText ?? '').length,
    }))
  : null;

const probe = parseTaggedJson(consoleMessages, 'POC_PROBE');
const benchmark = parseTaggedJson(consoleMessages, 'POC_BENCHMARK');
const validation = parseTaggedJson(consoleMessages, 'POC_VALIDATION');

const result = {
  browser: browserName,
  url,
  gotoOk,
  gotoError,
  domInfo,
  probe,
  benchmark,
  validation,
  consoleErrorCount: consoleMessages.filter((entry) => entry.type === 'error').length,
  consoleWarningCount: consoleMessages.filter((entry) => entry.type === 'warning').length,
  consoleMessages,
  pageErrors,
};

console.log(JSON.stringify(result, null, 2));

await browser.close();
