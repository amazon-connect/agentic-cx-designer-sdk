'use strict';

/**
 * Flow template for OrderLookup.
 *
 * Derived from a real, working flow exported via GetFlow:
 *   start -> user_input -> data_request (OrderLookup)
 *     success      -> generative_text -> message({OutputSummary}) -> terminate
 *     timeout/fail -> "couldn't find that order" -> terminate
 *   generative_text timeout/fail -> "having trouble" -> terminate
 *
 * The user_input node writes the caller's utterance into the `orderNumber`
 * context variable (state modification); the data_request node reads it via
 * urlParams (`{orderNumber:NLX.Context}`) into the webhook URL path.
 *
 * Node ids are generated fresh on each build (they only need to be unique
 * within the flow). The `dataRequestId` is injected so the flow references the
 * OrderLookup data request.
 */

const { randomUUID } = require('crypto');

const WELCOME_MESSAGE =
  "Welcome to order lookup! What's your order number? (Enter a number between 1 and 50.)";

const GEN_TEXT_PROMPT =
  'You are an order lookup assistant. Given the order details from the Data Request output, tell the customer in one or two friendly sentences how many items are in their order and the total. Report only the facts provided - do not invent shipping status or delivery dates.';

const NOT_FOUND_MESSAGE =
  "I couldn't find an order with that number. Please check it and try again.";

const ERROR_MESSAGE =
  'Sorry, I am having some trouble fetching your order details. Please try again later.';

const nodeStatusEq = (value) => ({
  left: { type: 'node_status' },
  operator: 'eq',
  right: { type: 'constant', value },
});

/**
 * Build the FlowNodeMap for OrderLookup.
 * @param {{ dataRequestId: string }} opts
 */
function buildNodes({ dataRequestId }) {
  if (!dataRequestId) throw new Error('buildNodes: dataRequestId is required');

  const START_NODE_ID = randomUUID();
  const USER_INPUT_NODE_ID = randomUUID();
  const DATA_REQUEST_NODE_ID = randomUUID();
  const GEN_TEXT_NODE_ID = randomUUID();
  const SUMMARY_MSG_NODE_ID = randomUUID();
  const NOT_FOUND_NODE_ID = randomUUID();
  const ERROR_NODE_ID = randomUUID();
  const TERMINATE_NODE_ID = randomUUID();

  return {
    [START_NODE_ID]: {
      nodeId: START_NODE_ID,
      type: 'start',
      childNodes: [{ nodeId: USER_INPUT_NODE_ID, conditions: [] }],
      messages: [],
      modalities: {},
      metadata: { stateModifications: [] },
    },
    [USER_INPUT_NODE_ID]: {
      nodeId: USER_INPUT_NODE_ID,
      type: 'user_input',
      childNodes: [
        { nodeId: DATA_REQUEST_NODE_ID, conditions: [{ left: { type: 'captured_flow' }, operator: 'exists' }] },
        { nodeId: DATA_REQUEST_NODE_ID, conditions: [{ left: { type: 'captured_flow' }, operator: 'not_exists' }] },
      ],
      messages: [{ type: 'text', body: WELCOME_MESSAGE, metadata: { alternatePhrasings: [] } }],
      modalities: {},
      metadata: {
        stateModifications: [
          {
            type: 'context',
            name: 'orderNumber',
            modification: 'set',
            value: { type: 'system', name: 'System.utterance' },
          },
        ],
      },
    },
    [DATA_REQUEST_NODE_ID]: {
      nodeId: DATA_REQUEST_NODE_ID,
      type: 'data_request',
      childNodes: [
        { nodeId: GEN_TEXT_NODE_ID, conditions: [nodeStatusEq('success')] },
        { nodeId: NOT_FOUND_NODE_ID, conditions: [nodeStatusEq('timeout')] },
        { nodeId: NOT_FOUND_NODE_ID, conditions: [nodeStatusEq('failure')] },
      ],
      dataRequests: [
        {
          dataRequestId,
          name: dataRequestId,
          urlParams: { orderNumber: '{orderNumber:NLX.Context}' },
          headers: {},
          payload: { type: 'recursive', value: {} },
          alwaysRetrigger: false,
        },
      ],
      messages: [],
      modalities: {},
      metadata: { stateModifications: [] },
    },
    [GEN_TEXT_NODE_ID]: {
      nodeId: GEN_TEXT_NODE_ID,
      type: 'generative_text',
      childNodes: [
        { nodeId: SUMMARY_MSG_NODE_ID, conditions: [nodeStatusEq('success')] },
        { nodeId: ERROR_NODE_ID, conditions: [nodeStatusEq('timeout')] },
        { nodeId: ERROR_NODE_ID, conditions: [nodeStatusEq('failure')] },
      ],
      messages: [],
      modalities: {},
      metadata: {
        generativeText: {
          name: 'OutputSummary',
          prompt: GEN_TEXT_PROMPT,
          modelType: 'amazon-nova-2-lite',
          temperature: 0.5,
          maxTokens: 4000,
        },
        stateModifications: [],
      },
    },
    [SUMMARY_MSG_NODE_ID]: {
      nodeId: SUMMARY_MSG_NODE_ID,
      type: 'basic',
      childNodes: [{ nodeId: TERMINATE_NODE_ID, conditions: [] }],
      messages: [{ type: 'text', body: '{OutputSummary:NLX.Local}', metadata: { alternatePhrasings: [] } }],
      modalities: {},
      metadata: { stateModifications: [] },
    },
    [NOT_FOUND_NODE_ID]: {
      nodeId: NOT_FOUND_NODE_ID,
      type: 'basic',
      childNodes: [{ nodeId: TERMINATE_NODE_ID, conditions: [] }],
      messages: [{ type: 'text', body: NOT_FOUND_MESSAGE, metadata: { alternatePhrasings: [] } }],
      modalities: {},
      metadata: { stateModifications: [] },
    },
    [ERROR_NODE_ID]: {
      nodeId: ERROR_NODE_ID,
      type: 'basic',
      childNodes: [{ nodeId: TERMINATE_NODE_ID, conditions: [] }],
      messages: [{ type: 'text', body: ERROR_MESSAGE, metadata: { alternatePhrasings: [] } }],
      modalities: {},
      metadata: { stateModifications: [] },
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

module.exports = { buildNodes };
