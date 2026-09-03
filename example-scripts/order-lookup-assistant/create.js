'use strict';

/**
 * OrderLookup — one-command create.
 *
 * Stands up an order-lookup assistant from scratch, in order:
 *   1. Data request (external webhook to the DummyJSON demo API)
 *   2. Flow wired to the data request (user_input -> data_request ->
 *      generative_text -> message; with not-found / error branches)
 *   3. Application with the flow attached
 *
 * Every step is idempotent (create-or-update).
 *
 * Run with:  npm run order:create
 */

const { makeClient } = require('../lib/client');
const { ensureDataRequestStep } = require('./data-request');
const { ensureFlowStep } = require('./flow');
const { ensureApplicationStep } = require('./application');

(async () => {
  const client = makeClient();
  try {
    console.log('Creating the OrderLookup application ...\n');

    const { dataRequestId } = await ensureDataRequestStep(client);
    console.log('');

    await ensureFlowStep(client, { dataRequestId });
    console.log('');

    const { applicationId } = await ensureApplicationStep(client);

    console.log('\nCreate complete.');
    console.log(`  application: order-lookup (${applicationId})`);
    console.log('  Next: run "npm run order:build-deploy" to make it runnable.');
  } catch (e) {
    console.error('\nCreate failed:', e.name, '-', e.message);
    if (e.$metadata) console.error('HTTP', e.$metadata.httpStatusCode);
    process.exitCode = 1;
  }
})();
