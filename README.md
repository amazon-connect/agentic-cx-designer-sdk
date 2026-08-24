# Agentic CX Designer SDK

TypeScript SDK client for Amazon Connect Agentic CX Designer — provides programmatic access to workspace resources including applications, flows, knowledge bases, guardrails, and more.

## Installation

```bash
npm install amazon-connect-acxd-sdk
```

## Usage

```javascript
import { AgenticCXDesignerClient, ListApplicationsCommand } from "amazon-connect-acxd-sdk";

const client = new AgenticCXDesignerClient({
  region: "us-west-2",
  apiKey: "REPLACE_WITH_API_KEY",
  workspaceId: "REPLACE_WITH_WORKSPACE_ID",
});

const response = await client.send(new ListApplicationsCommand({}));
console.log(response.items);
```

## Examples

Pass your API key and workspace ID directly to the client constructor. Every
request is then authenticated automatically — no middleware to wire up. The
examples below share a single `client`:

```javascript
import { AgenticCXDesignerClient } from "amazon-connect-acxd-sdk";

const client = new AgenticCXDesignerClient({
  region: "us-west-2",
  apiKey: process.env.ACXD_API_KEY,
  workspaceId: process.env.ACXD_WORKSPACE_ID,
});
```

### Creating a programmatic user

Programmatic users are the machine identities that authenticate with the SDK. A
`roleConfig` determines their access — either an account-level role (full access
across all workspaces) or workspace-scoped roles. Only account administrators can
create them.

```javascript
import { CreateProgrammaticUserCommand } from "amazon-connect-acxd-sdk";

// Account-level administrator — full access across all workspaces.
const admin = await client.send(
  new CreateProgrammaticUserCommand({
    name: "ci-deploy-bot",
    roleConfig: { accountRole: "administrator" },
  })
);
console.log(admin.userId);

// Or scope access per workspace, using a predefined role or a custom role ID.
const scoped = await client.send(
  new CreateProgrammaticUserCommand({
    name: "support-readonly-bot",
    roleConfig: {
      workspaceRoles: [
        { workspaceId: "REPLACE_WITH_WORKSPACE_ID", role: "readOnly" },
        { workspaceId: "REPLACE_WITH_OTHER_WORKSPACE_ID", roleId: "REPLACE_WITH_CUSTOM_ROLE_ID" },
      ],
    },
  })
);
```

Generate an API key for the user in NLX Studio → Admin Hub (max 2 per user); the
key is shown only once.

### Applications

Applications are the top-level container for flows, builds, and deployments.

```javascript
import {
  ListApplicationsCommand,
  CreateApplicationCommand,
  GetApplicationCommand,
  UpdateApplicationCommand,
  DeleteApplicationCommand,
} from "amazon-connect-acxd-sdk";

// List
const { items } = await client.send(new ListApplicationsCommand({ maxResults: 20 }));

// Create — name, flows, and settings are required.
const created = await client.send(
  new CreateApplicationCommand({
    name: "My Support Bot",
    description: "Handles customer support inquiries",
    flows: [{ flowId: "MainFlow" }],
    settings: {
      languageCode: "en-US",
      languageCodes: ["en-US"],
      conversationTTL: 5,
    },
    metadata: { path: "/production", tags: ["support"] },
  })
);
const applicationId = created.applicationId;

// Get
const app = await client.send(
  new GetApplicationCommand({ applicationIdentifier: applicationId })
);

// Update — send only the fields you want to change.
await client.send(
  new UpdateApplicationCommand({
    applicationIdentifier: applicationId,
    description: "Handles support and billing inquiries",
  })
);

// Delete
await client.send(
  new DeleteApplicationCommand({ applicationIdentifier: applicationId })
);
```

### Flows

Flows define conversational logic as a graph of typed nodes.

```javascript
import {
  ListFlowsCommand,
  CreateFlowCommand,
  GetFlowCommand,
  UpdateFlowCommand,
  DeleteFlowCommand,
} from "amazon-connect-acxd-sdk";

// List
const { items } = await client.send(new ListFlowsCommand({ maxResults: 20 }));

// Create — flowId, utterances, description, and nodes are required.
await client.send(
  new CreateFlowCommand({
    flowId: "MainFlow",
    description: "Primary support flow",
    aiDescription: "Handles customer support inquiries about orders and returns",
    mainLanguageCode: "en-US",
    utterances: [{ text: "I need help with my order" }, { text: "order status" }],
    nodes: {
      "11111111-1111-4111-8111-111111111111": {
        nodeId: "11111111-1111-4111-8111-111111111111",
        type: "start",
        childNodes: [{ nodeId: "22222222-2222-4222-8222-222222222222" }],
      },
      "22222222-2222-4222-8222-222222222222": {
        nodeId: "22222222-2222-4222-8222-222222222222",
        type: "basic",
        messages: [{ type: "text", body: "How can I help you today?" }],
        childNodes: [],
      },
    },
    metadata: { path: "/support", tags: ["production"] },
  })
);

// Get a single flow, including all its nodes.
const flow = await client.send(
  new GetFlowCommand({ flowIdentifier: "MainFlow" })
);

// Update — send only the fields you want to change.
await client.send(
  new UpdateFlowCommand({
    flowIdentifier: "MainFlow",
    description: "Primary support and returns flow",
  })
);

// Delete
await client.send(new DeleteFlowCommand({ flowIdentifier: "MainFlow" }));
```

### Paginating list results

List operations return a `nextToken` when more results are available. Pass it back
to fetch the next page; iterate until it is absent.

```javascript
import { ListApplicationsCommand } from "amazon-connect-acxd-sdk";

async function listAllApplications() {
  const all = [];
  let nextToken;

  do {
    const page = await client.send(
      new ListApplicationsCommand({ maxResults: 50, nextToken })
    );
    all.push(...page.items);
    nextToken = page.nextToken;
  } while (nextToken);

  return all;
}
```

### Handling errors

Operations throw typed exceptions you can branch on by `name`.

```javascript
import { GetApplicationCommand } from "amazon-connect-acxd-sdk";

try {
  const app = await client.send(
    new GetApplicationCommand({ applicationIdentifier: "00000000-0000-4000-8000-000000000000" })
  );
} catch (err) {
  switch (err.name) {
    case "ResourceNotFoundException":
      // 404 — the application does not exist.
      break;
    case "ValidationException":
      // 400 — check err.fieldList for per-field details.
      break;
    case "ThrottlingException":
      // 429 — retry with backoff.
      break;
    default:
      throw err;
  }
}
```

## Architecture

This repository contains the [Smithy](https://smithy.io) model that defines the Agentic CX Designer API. The TypeScript SDK client is generated from this model using [smithy-typescript-codegen](https://github.com/smithy-lang/smithy-typescript) and published to npm.

```
model/               <- Smithy model files (API source of truth)
smithy-build.json    <- Codegen configuration (TypeScript client + Maven deps)
.github/workflows/   <- CI: build, publish, CodeQL scanning
```

## Development

### Prerequisites

- [Smithy CLI](https://smithy.io/2.0/guides/smithy-cli/cli_installation.html) (1.72.0+)
- Node.js 22+
- Java 17+ (required by Smithy CLI)

### Generate and build the SDK locally

```bash
# Generate TypeScript client from Smithy model
smithy build

# Build the generated client
cd build/smithy/typescript-client/typescript-codegen
npm install
npm run build

# Test it
node -e "const sdk = require('.'); console.log(Object.keys(sdk).length, 'exports')"
```

### Endpoint resolution

The SDK resolves the service endpoint from the region:

| Configuration | Endpoint |
|---|---|
| `region: 'us-west-2'` | `https://api.acxd.connect.us-west-2.amazonaws.com` |
| `endpoint: 'https://custom-url'` | Uses the override (for testing) |

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for how to report security issues.

## License

This project is licensed under the Apache-2.0 License. See [LICENSE](LICENSE).
