'use strict';

/**
 * AutoCare Voice Assistant - content-safety guardrail.
 *
 * Creates (idempotently) a guardrail applied to the caller's input, and returns
 * its id so the application step can attach it via settings.guardrails.
 *
 * The guardrail applies Amazon's Bedrock-Guardrails baseline principles to
 * ACXD's rule-based guardrail resource: keep the assistant on-topic, flag
 * profanity, and mask PII. Guardrails are defense-in-depth, not a security
 * guarantee - validate at the API layer too.
 *
 * Exports `ensureGuardrailStep(client)` returning the guardrailId, and runs
 * standalone via:  npm run autocare:guardrail
 */

const { makeClient } = require('../lib/client');
const { createGuardrail } = require('../lib/ensure');

const GUARDRAIL = {
  name: 'content-safety',
  trigger: 'input',
  active: true,
  description: 'Content-safety guardrail: stay on-topic, flag profanity, mask emails.',
  rules: [
    {
      name: 'StayOnTopic',
      active: true,
      description: 'Keep the assistant on its intended topic.',
      detection: {
        method: 'llmJudge',
        prompt:
          'Does the user message ask for legal, medical, or financial advice, or is it clearly unrelated to a customer-service assistant? Answer yes or no.',
        threshold: 0.7,
      },
      enforcement: {
        action: 'flag',
        behavior: { message: 'I can only help with questions about our services. Is there something along those lines I can help with?' },
      },
    },
    {
      name: 'BlockProfanity',
      active: true,
      description: 'Flag messages containing profanity.',
      detection: { method: 'keyword', keywords: ['damn', 'hell', 'crap'] },
      enforcement: { action: 'flag', behavior: { message: 'Let us keep it friendly. How can I help?' } },
    },
    {
      name: 'MaskEmail',
      active: true,
      description: 'Mask email addresses in user input.',
      detection: { method: 'regex', pattern: '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}' },
      enforcement: { action: 'mask', behavior: { maskChar: '*' } },
    },
  ],
};

async function ensureGuardrailStep(client) {
  console.log(`Guardrail "${GUARDRAIL.name}":`);
  const result = await createGuardrail(client, GUARDRAIL);
  console.log(`  CREATED - guardrailId=${result.guardrailId}`);
  return { guardrailId: result.guardrailId };
}

module.exports = { ensureGuardrailStep, GUARDRAIL };

if (require.main === module) {
  (async () => {
    try {
      await ensureGuardrailStep(makeClient());
      console.log('\nDone.');
    } catch (e) {
      console.error('ERROR', e.name, '-', e.message);
      if (e.$metadata) console.error('HTTP', e.$metadata.httpStatusCode);
      process.exitCode = 1;
    }
  })();
}
