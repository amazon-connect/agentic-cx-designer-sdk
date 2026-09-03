'use strict';

/**
 * OrderLookup — data request step.
 *
 * Ensures the OrderLookup data request (an external webhook) that fetches order
 * details from the DummyJSON demo API by order number.
 *
 * IMPORTANT: the webhook url must live inside `environments`, not as a bare
 * top-level `url`. The runtime only substitutes URL path placeholders (like
 * `{orderNumber}`) for external webhooks that have an `environments` map — a
 * bare `url` is sent verbatim (the literal `{orderNumber}` -> 404).
 *
 * Exports `ensureDataRequestStep(client)`, and runs standalone via:
 *   npm run order:datarequest
 */

const { makeClient } = require('../lib/client');
const { ensureDataRequest } = require('../lib/ensure');

const DATA_REQUEST_ID = 'OrderLookup';
const ORDER_URL = 'https://dummyjson.com/carts/{orderNumber}';

async function ensureDataRequestStep(client) {
  console.log(`Data request "${DATA_REQUEST_ID}":`);
  const result = await ensureDataRequest(client, {
    dataRequestId: DATA_REQUEST_ID,
    type: 'object',
    webhook: {
      implementation: 'external',
      method: 'GET',
      environments: {
        production: { url: ORDER_URL },
        development: { url: ORDER_URL },
      },
    },
    description: 'Fetch order (cart) details from the DummyJSON demo API by order number.',
  });
  console.log(`  ${result.action.toUpperCase()} — dataRequestId=${DATA_REQUEST_ID}`);
  return { dataRequestId: DATA_REQUEST_ID };
}

module.exports = { ensureDataRequestStep, DATA_REQUEST_ID };

if (require.main === module) {
  (async () => {
    try {
      await ensureDataRequestStep(makeClient());
      console.log('\nDone.');
    } catch (e) {
      console.error('ERROR', e.name, '-', e.message);
      if (e.$metadata) console.error('HTTP', e.$metadata.httpStatusCode);
      process.exitCode = 1;
    }
  })();
}
