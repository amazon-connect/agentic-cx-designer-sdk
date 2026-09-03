'use strict';

/**
 * Trailhead Assistant - slot type step.
 *
 * Ensures the YesOrNo slot type the user_choice node branches on, with fixed
 * value ids so the flow's conditions reference stable ids across workspaces.
 *
 * Exports `ensureSlotTypeStep(client)` returning the value ids, and runs
 * standalone via:  npm run trailhead:slot
 */

const { makeClient } = require('../lib/client');
const { createSlotType } = require('../lib/ensure');

const SLOT_TYPE_ID = 'YesOrNo';
const YES_VALUE_ID = 'YesValueId';
const NO_VALUE_ID = 'NoValueId';

async function ensureSlotTypeStep(client) {
  console.log(`Slot type "${SLOT_TYPE_ID}":`);
  const result = await createSlotType(client, {
    slotTypeId: SLOT_TYPE_ID,
    values: [
      { value: 'Yes', valueId: YES_VALUE_ID, synonyms: ['yes', 'yeah', 'yep', 'sure'] },
      { value: 'No', valueId: NO_VALUE_ID, synonyms: ['no', 'nope', 'nah'] },
    ],
  });
  console.log(`  CREATED - slotTypeId=${SLOT_TYPE_ID}`);
  return { yesValueId: YES_VALUE_ID, noValueId: NO_VALUE_ID };
}

module.exports = { ensureSlotTypeStep };

if (require.main === module) {
  (async () => {
    try {
      await ensureSlotTypeStep(makeClient());
      console.log('\nDone.');
    } catch (e) {
      console.error('ERROR', e.name, '-', e.message);
      if (e.$metadata) console.error('HTTP', e.$metadata.httpStatusCode);
      process.exitCode = 1;
    }
  })();
}
