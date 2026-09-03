'use strict';

/**
 * Flow template for the Trailhead Assistant.
 *
 * Derived from a real, working flow exported via GetFlow:
 *   start -> user_input -> knowledge_base -> generative_text -> user_choice
 *            -> (Yes) basic -> terminate
 *            -> (No)  escalate -> terminate
 * KB no_match/timeout/failure and generative timeout/failure route to a
 * terminate node. Runtime-only fields (saveId, timestamps) are omitted.
 *
 * The knowledge base id and the YesNo slot value ids are injected at build
 * time. Node ids are generated fresh on each build (they only need to be unique
 * within the flow).
 */

const { randomUUID } = require('crypto');

const SLOT_TYPE_ID = 'YesOrNo';

const WELCOME_MESSAGE =
  'Welcome to Cedar Ridge National Park! I can help with trails, permits, fees, wildlife safety, and park hours. What would you like to know?';

const GEN_TEXT_PROMPT =
  'You are the Cedar Ridge National Park visitor assistant. Rephrase the retrieved knowledge base answer into a warm, concise, encouraging reply for a visitor, in one to three sentences. Keep all facts (hours, prices, permit rules, safety instructions) exactly as given - do not invent or change any details. If the answer suggests contacting a ranger, gently offer that option.';

const nodeStatusEq = (value) => ({
  left: { type: 'node_status' },
  operator: 'eq',
  right: { type: 'constant', value },
});

/**
 * Build the FlowNodeMap for the trailhead assistant.
 * @param {{ knowledgeBaseId: string, yesValueId: string, noValueId: string }} opts
 */
function buildNodes({ knowledgeBaseId, yesValueId, noValueId }) {
  if (!knowledgeBaseId) throw new Error('buildNodes: knowledgeBaseId is required');
  if (!yesValueId || !noValueId) throw new Error('buildNodes: yesValueId and noValueId are required');

  // Fresh node ids per build. Node ids only need to be unique within the flow,
  // so a new set each run is fine (the flow structure is identical).
  const START_NODE_ID = randomUUID();
  const USER_INPUT_NODE_ID = randomUUID();
  const KB_NODE_ID = randomUUID();
  const GEN_TEXT_NODE_ID = randomUUID();
  const USER_CHOICE_NODE_ID = randomUUID();
  const YES_NODE_ID = randomUUID();
  const ESCALATE_NODE_ID = randomUUID();
  const END_NODE_ID = randomUUID();
  const FALLBACK_END_NODE_ID = randomUUID();

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
      // Route to the knowledge base whether or not a flow was recognized, so
      // every utterance is answered from the KB. Both captured_flow branches
      // are kept explicit to match how the UI renders user_input edges.
      childNodes: [
        { nodeId: KB_NODE_ID, conditions: [{ left: { type: 'captured_flow' }, operator: 'exists' }] },
        { nodeId: KB_NODE_ID, conditions: [{ left: { type: 'captured_flow' }, operator: 'not_exists' }] },
      ],
      messages: [
        { type: 'text', body: WELCOME_MESSAGE, metadata: { alternatePhrasings: [] } },
      ],
      modalities: {},
      metadata: { stateModifications: [] },
    },
    [KB_NODE_ID]: {
      nodeId: KB_NODE_ID,
      type: 'knowledge_base',
      childNodes: [
        { nodeId: GEN_TEXT_NODE_ID, conditions: [nodeStatusEq('match')] },
        { nodeId: FALLBACK_END_NODE_ID, conditions: [nodeStatusEq('no_match')] },
        { nodeId: FALLBACK_END_NODE_ID, conditions: [nodeStatusEq('timeout')] },
        { nodeId: FALLBACK_END_NODE_ID, conditions: [nodeStatusEq('failure')] },
      ],
      messages: [],
      modalities: {},
      metadata: {
        knowledgeBase: {
          knowledgeBaseId,
          name: 'KbArticle',
          question: '{System.utterance:NLX.System}',
          includeCitation: false,
          filters: { items: [], operator: 'or' },
        },
        stateModifications: [],
      },
    },
    [GEN_TEXT_NODE_ID]: {
      nodeId: GEN_TEXT_NODE_ID,
      type: 'generative_text',
      childNodes: [
        { nodeId: USER_CHOICE_NODE_ID, conditions: [nodeStatusEq('success')] },
        { nodeId: FALLBACK_END_NODE_ID, conditions: [nodeStatusEq('timeout')] },
        { nodeId: FALLBACK_END_NODE_ID, conditions: [nodeStatusEq('failure')] },
      ],
      messages: [],
      modalities: {},
      metadata: {
        generativeText: {
          name: 'GeneratedReply',
          prompt: GEN_TEXT_PROMPT,
          modelType: 'amazon-nova-2-lite',
          temperature: 0.5,
          maxTokens: 4000,
        },
        stateModifications: [],
      },
    },
    [USER_CHOICE_NODE_ID]: {
      nodeId: USER_CHOICE_NODE_ID,
      type: 'user_choice',
      childNodes: [
        {
          nodeId: YES_NODE_ID,
          conditions: [
            {
              left: { type: 'slot_value_id', name: SLOT_TYPE_ID },
              operator: 'eq',
              right: { type: 'constant_id', value: yesValueId },
            },
          ],
        },
        {
          nodeId: ESCALATE_NODE_ID,
          conditions: [
            {
              left: { type: 'slot_value_id', name: SLOT_TYPE_ID },
              operator: 'eq',
              right: { type: 'constant_id', value: noValueId },
            },
          ],
        },
        {
          nodeId: END_NODE_ID,
          conditions: [{ left: { type: 'slot', name: SLOT_TYPE_ID }, operator: 'not_exists' }],
        },
      ],
      messages: [
        {
          type: 'text',
          body: '{GeneratedReply:NLX.Local}. Did that answer your question? ',
          metadata: { alternatePhrasings: [] },
        },
      ],
      modalities: {},
      metadata: {
        choice: {
          source: 'slotType',
          slotTypeId: SLOT_TYPE_ID,
          selectedChoiceLabel: SLOT_TYPE_ID,
          showChoices: false,
          choiceDisplayFormat: 'dropdown',
        },
        stateModifications: [],
      },
    },
    [YES_NODE_ID]: {
      nodeId: YES_NODE_ID,
      type: 'basic',
      childNodes: [{ nodeId: END_NODE_ID, conditions: [] }],
      messages: [
        { type: 'text', body: 'Great, enjoy your visit to Cedar Ridge!', metadata: { alternatePhrasings: [] } },
      ],
      modalities: {},
      metadata: { stateModifications: [] },
    },
    [ESCALATE_NODE_ID]: {
      nodeId: ESCALATE_NODE_ID,
      type: 'escalate',
      childNodes: [{ nodeId: END_NODE_ID, conditions: [nodeStatusEq('continuation')] }],
      messages: [],
      modalities: {},
      metadata: { stateModifications: [] },
    },
    [END_NODE_ID]: {
      nodeId: END_NODE_ID,
      type: 'terminate',
      childNodes: [],
      messages: [],
      modalities: {},
      metadata: { stateModifications: [] },
    },
    [FALLBACK_END_NODE_ID]: {
      nodeId: FALLBACK_END_NODE_ID,
      type: 'terminate',
      childNodes: [],
      messages: [],
      modalities: {},
      metadata: { stateModifications: [] },
    },
  };
}

module.exports = { buildNodes, SLOT_TYPE_ID };
