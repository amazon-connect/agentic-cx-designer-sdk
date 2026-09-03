# ACXD Example Scripts

Pre-manufactured example setups built on the
[`amazon-connect-acxd-sdk`](https://github.com/amazon-connect/agentic-cx-designer-sdk).
Each example stands up a complete, working ACXD application in your workspace
with a single command — a knowledge base, a flow, and an application, built and
deployed — so you have something real to start from instead of a blank
workspace.

Each example creates a fresh set of resources. If a resource it would create
already exists (same name/id), the script stops with a clear "already exists"
message rather than modifying it — so it never silently clobbers existing work.
To start over, delete the resources (or the application) and run again.

## Prerequisites

- **Node.js 18 or newer.**
- An **ACXD workspace** and an **API key** for it (format `acxd_live_<prefix>.<secret>`).
  See [Getting an API key](../README.md#getting-an-api-key) in the SDK README for
  how to generate one.

## Setup

1. Install dependencies:

   ```bash
   npm install
   ```

2. Copy the example environment file and fill in your values:

   ```bash
   cp .env.example .env
   ```

   ```
   ACXD_API_KEY=acxd_live_...
   ACXD_WORKSPACE_ID=<your-workspace-id>
   ACXD_REGION=ca-central-1
   ```

   `.env` is gitignored — never commit your API key.

   Alternatively, export the variables directly in your shell instead of using a
   `.env` file — the scripts read them from the environment either way:

   ```bash
   export ACXD_API_KEY=acxd_live_...
   export ACXD_WORKSPACE_ID=<your-workspace-id>
   export ACXD_REGION=ca-central-1
   ```

## Examples

Each example is a two-stage lifecycle:

1. **create** — provisions the ACXD resources (knowledge base, flow,
   application) in your workspace.
2. **build-deploy** — builds the application and deploys it so it becomes
   runnable.

Run `create` first, then `build-deploy`.

### AutoCare — voice assistant

A voice assistant for a fictional car-repair shop. Demonstrates an **agentic
voice** experience: a single Generative Journey node with a prompt that answers
caller questions about hours, pricing, and services from an attached knowledge
base.

```bash
npm run autocare:create
npm run autocare:build-deploy
```

Creates:
- Knowledge base `autocare-faq` (hours, pricing, services)
- Flow `AutoCareAssistant` (`start -> generative_journey -> terminate`, with the
  knowledge base attached to the generative node as a tool)
- Application `autocare-assistant` with the flow set as the welcome flow

Individual steps are also available: `autocare:kb`, `autocare:flow`,
`autocare:app`, `autocare:guardrail`.

AutoCare also attaches a **content-safety guardrail** (`content-safety`) to the
application, screening caller input: keep the assistant on-topic (llmJudge), flag
profanity (keyword), and mask email addresses (regex). Guardrails apply Amazon's
Bedrock-Guardrails baseline principles to ACXD's rule-based guardrail resource,
and are **defense-in-depth, not a security guarantee** — you should still
validate input and output at the API layer.

### Trailhead — national park visitor assistant

A text assistant for a fictional national park (Cedar Ridge). Demonstrates a
**structured, multi-node flow**: capture the visitor's question, look it up in a
knowledge base, rephrase the answer with a generative text node, then ask "did
that help?" and escalate to a ranger on "no".

```bash
npm run trailhead:create
npm run trailhead:build-deploy
```

Creates:
- Knowledge base `cedarridge-faq` (trails, permits, fees, wildlife safety)
- Slot type `YesOrNo` (used by the choice node)
- Flow `TrailheadAssistant`
  (`start -> user_input -> knowledge_base -> generative_text -> user_choice ->
  escalate | end`)
- Application `trailhead-assistant` with the flow set as the welcome flow

Individual steps are also available: `trailhead:kb`, `trailhead:slot`,
`trailhead:flow`, `trailhead:app`.

### OrderLookup — order status assistant (external API)

An assistant that looks up order details from an **external API**. Demonstrates
the `data_request` node: capture the caller's order number, call a public API
with it, and summarize the result — with graceful not-found and error handling.

```bash
npm run order:create
npm run order:build-deploy
```

Creates:
- Data request `OrderLookup` (an external webhook: `GET https://dummyjson.com/carts/{orderNumber}`)
- Flow `OrderLookup`
  (`start -> user_input -> data_request -> generative_text -> message ->
  terminate`, with not-found and error branches)
- Application `order-lookup` with the flow set as the welcome flow

The caller's order number is captured into an `orderNumber` context variable (a
state modification on the user_input node) and passed into the webhook URL.

Individual steps are also available: `order:datarequest`, `order:flow`,
`order:app`.

> **External dependency:** this example calls the public
> [DummyJSON](https://dummyjson.com) demo API (`/carts/{id}`), treating a cart as
> a stand-in "order". Valid order numbers are roughly 1-50; other numbers return
> not-found (which the flow handles). The API returns order contents and totals
> only — it has no shipping status or tracking, so the assistant reports just the
> facts it receives.

## Project structure

```
.
├── lib/
│   ├── client.js     # builds the SDK client from ACXD_* env vars
│   └── ensure.js     # resource create helpers (application, flow, knowledge
│                     #   base, articles, slot type, data request, guardrail)
│                     #   plus deployApplication
├── autocare-voice-assistant/
├── trailhead-assistant/
└── order-lookup-assistant/
```

The shared helpers create each resource by its natural key (name / id) and fail
with a clear error if it already exists, so a re-run never modifies existing
resources. `deployApplication` is the exception: it uses the single deployment
slot, creating it the first time and updating it on later deploys.

## Notes

- **Knowledge base and article content is illustrative demo data** for fictional
  businesses. Edit the `kb-content.js` file in an example to change it.
- Text sent to ACXD (knowledge base descriptions, article bodies) must be
  printable ASCII — use `-` rather than an em-dash, for example.
- An application/environment has a single deployment slot: the first deploy
  creates it, and subsequent deploys update it in place to the latest build.
