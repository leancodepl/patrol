const { chromium } = require('playwright');

(async () => {
  const baseUrl = process.argv[2] || 'http://localhost:8080';
  const browser = await chromium.launch({ 
    headless: false,
    slowMo: 1000, // 1 second delay between actions
  });
  const context = await browser.newContext();
  const page = await context.newPage();

  // Expose patrolNative binding for Dart->Playwright communication
  await page.exposeBinding('patrolNative', async ({ page }, requestJson) => {
    try {
      const request = JSON.parse(requestJson);
      const { action, params } = request;
      
      console.log(`[patrolNative] Action: ${action}`, params);
      
      switch (action) {
        case 'grantPermissions': {
          const origin = params.origin || new URL(page.url()).origin;
          await page.context().grantPermissions(params.permissions || [], { origin });
          console.log(`[patrolNative] Granted permissions: ${params.permissions?.join(', ')} for ${origin}`);
          return JSON.stringify({ ok: true });
        }
        
        default:
          const error = `Unknown action: ${action}`;
          console.error(`[patrolNative] ${error}`);
          return JSON.stringify({ ok: false, error });
      }
    } catch (e) {
      const error = `Failed to execute: ${e.message}`;
      console.error(`[patrolNative] ${error}`);
      return JSON.stringify({ ok: false, error });
    }
  });

  console.log(`Opening ${baseUrl}`);
  await page.goto(baseUrl, { waitUntil: 'load' });

  // Wait for Patrol web service to expose hooks
  await page.waitForFunction(() => {
    return typeof window.__patrol_listDartTests === 'function' &&
           typeof window.__patrol_runDartTestWithCallback === 'function';
  }, { timeout: 120000 });

  const listResp = await page.evaluate(() => {
    return JSON.parse(window.__patrol_listDartTests());
  });

  const group = listResp.group;
  const collectTests = (g, parentName = '') => {
    const tests = [];
    
    if (g.type === 'test') {
      // For individual tests, combine parent group name with test name
      const fullName = parentName ? `${parentName} ${g.name}` : g.name;
      tests.push(fullName);
    }
    
    if (g.entries) {
      for (const e of g.entries) {
        if (e.type === 'group') {
          // For groups, pass the group name as parent for nested tests
          const groupName = parentName ? `${parentName} ${e.name}` : e.name;
          tests.push(...collectTests(e, groupName));
        } else if (e.type === 'test') {
          // For tests directly under this group
          const fullName = parentName ? `${parentName} ${e.name}` : e.name;
          tests.push(fullName);
        }
      }
    }
    
    return tests;
  };

  const tests = collectTests(group);
  console.log(`Discovered ${tests.length} test(s):`);
  tests.forEach(test => console.log(`  - ${test}`));

  const results = [];
  for (let i = 0; i < tests.length; i++) {
    const name = tests[i];
    console.log(`\nRunning: ${name}`);
    
    // Option 1: Using callback-based approach (recommended)
    const resp = await page.evaluate((n) => {
      return new Promise((resolve) => {
        window.__patrol_runDartTestWithCallback(n, (result) => {
          resolve(JSON.parse(result));
        });
      });
    }, name);
    
    results.push({ name, result: resp.result, details: resp.details });
    console.log(`Result: ${name} -> ${resp.result}`);
    
    // Reload page after each test (except the last one) to ensure clean state for next test
    if (i < tests.length - 1) {
      console.log('Reloading page for next test...');
      await page.reload({ waitUntil: 'load' });
      
      // Wait for Patrol web service to be ready again after reload
      await page.waitForFunction(() => {
        return typeof window.__patrol_listDartTests === 'function' &&
               typeof window.__patrol_runDartTestWithCallback === 'function';
      }, { timeout: 30000 });
      
      console.log('Page reloaded, ready for next test');
    }
  }

  await browser.close();

  const failures = results.filter(r => r.result !== 'success');
  console.log(`\nSummary: ${results.length - failures.length} passed, ${failures.length} failed`);
  if (failures.length > 0) {
    process.exitCode = 1;
  }
})();
