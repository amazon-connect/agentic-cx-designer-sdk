'use strict';

/**
 * Flow template for the AutoCare Voice Assistant.
 *
 * Derived from a real, working flow (start -> generative_journey -> terminate)
 * exported via GetFlow, so the node structure is known-valid. Runtime-only
 * fields (saveId, timestamps) are omitted. The generative_journey node's KB
 * tool and prompt are injected at build time so the flow points at the KB we
 * create from the SDK.
 *
 * Node ids are fixed (not random) so re-running is a clean update rather than
 * producing a structurally-different graph each time.
 */

const START_NODE_ID = '9deed177-41fa-4707-bec9-843b4df1b377';
const JOURNEY_NODE_ID = '56dde33b-2ac5-4e28-999b-623634ffbed3';
const TERMINATE_NODE_ID = 'ab770c0d-74a1-40fa-b88a-1162ffc276ff';

// Keep prompts ASCII: several ACXD validators (KB description, article bodies)
// reject non-ASCII such as the em-dash (U+2014). Use hyphens.
const DEFAULT_PROMPT = [
  'You are "AutoCare Assistant," the friendly voice agent for AutoCare Auto Repair, a car repair and detailing shop. You answer calls from customers over the phone, so keep every response short, natural, and conversational - one or two sentences, no lists or long paragraphs, since the caller is listening, not reading.',
  '',
  'Your job:',
  '1. Greet the caller warmly and ask how you can help.',
  '2. Answer questions about our hours, pricing, and services using ONLY the information in the connected knowledge base. Do not make up prices, hours, or policies.',
  "3. If a caller asks about pricing, give the specific price from the knowledge base. If they mention they're a returning customer, apply and mention the returning-customer price.",
  '4. If a caller wants to book an appointment or asks something you cannot answer from the knowledge base (like account-specific or order-specific questions), offer to transfer them to a human service advisor.',
  "5. If you don't understand or the caller goes quiet, politely ask them to repeat.",
  '',
  "Tone: warm, professional, efficient - like a helpful front-desk person at a trusted local garage. Never invent details. If the knowledge base doesn't cover something, say you're not sure and offer to connect them to a service advisor.",
].join('\n');

/**
 * Build the FlowNodeMap for the starter, wiring in the given knowledge base.
 * @param {{ knowledgeBaseId: string, prompt?: string }} opts
 */
function buildNodes({ knowledgeBaseId, prompt = DEFAULT_PROMPT }) {
  if (!knowledgeBaseId) throw new Error('buildNodes: knowledgeBaseId is required');

  return {
    [START_NODE_ID]: {
      nodeId: START_NODE_ID,
      type: 'start',
      childNodes: [{ nodeId: JOURNEY_NODE_ID, conditions: [] }],
      messages: [],
      modalities: {},
      metadata: { stateModifications: [] },
    },
    [JOURNEY_NODE_ID]: {
      nodeId: JOURNEY_NODE_ID,
      type: 'generative_journey',
      childNodes: [
        {
          nodeId: TERMINATE_NODE_ID,
          conditions: [
            {
              left: { type: 'node_status' },
              operator: 'eq',
              right: { type: 'constant', value: 'timeout' },
            },
          ],
        },
        {
          conditions: [
            {
              left: { type: 'node_status' },
              operator: 'eq',
              right: { type: 'constant', value: 'failure' },
            },
          ],
        },
      ],
      messages: [],
      modalities: {},
      metadata: {
        generativeJourney: {
          tools: [{ type: 'knowledgeBase', scopeTags: [], knowledgeBaseId }],
          prompt,
          modelType: 'amazon-nova-2-lite',
          exitConditions: [],
          enableZeroTurnMode: false,
          maxTokens: 8192,
          maxSteps: 10,
          temperature: 0.7,
        },
        stateModifications: [],
      },
    },
    [TERMINATE_NODE_ID]: {
      nodeId: TERMINATE_NODE_ID,
      type: 'terminate',
      childNodes: [],
      messages: [],
      modalities: {},
      metadata: { stateModifications: [] },
    },
  };
}

module.exports = { buildNodes, DEFAULT_PROMPT };
