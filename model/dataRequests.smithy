// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
$version: "2"

namespace com.amazon.connect.acxd.sdk

// ============================================================================
// Operations — DataRequests
// ============================================================================
/// Lists all data requests for the workspace, paginated.
@http(method: "GET", uri: "/sdk/data-requests")
@readonly
@paginated(inputToken: "nextToken", outputToken: "nextToken", items: "items", pageSize: "maxResults")
operation ListDataRequests {
    input: ListDataRequestsRequest
    output: ListDataRequestsResponse
    errors: [
        ValidationException
        InternalServerException
    ]
}

/// Creates a new data request.
@http(method: "POST", uri: "/sdk/data-requests", code: 201)
operation CreateDataRequest {
    input: CreateDataRequestRequest
    output: DataRequest
    errors: [
        ValidationException
        ConflictException
        InternalServerException
    ]
}

/// Retrieves a single data request by ID.
@http(method: "GET", uri: "/sdk/data-requests/{dataRequestIdentifier}")
@readonly
operation GetDataRequest {
    input: GetDataRequestRequest
    output: DataRequest
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

/// Updates an existing data request.
@http(method: "PATCH", uri: "/sdk/data-requests/{dataRequestIdentifier}")
@idempotent
operation UpdateDataRequest {
    input: UpdateDataRequestRequest
    output: DataRequest
    errors: [
        ResourceNotFoundException
        ValidationException
        InternalServerException
    ]
}

/// Deletes a data request by ID.
@http(method: "DELETE", uri: "/sdk/data-requests/{dataRequestIdentifier}", code: 204)
@idempotent
operation DeleteDataRequest {
    input: DeleteDataRequestRequest
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

// ============================================================================
// Custom Types — DataRequests
// ============================================================================
/// Data request identifier — alphanumeric characters only.
@pattern("^[A-Za-z0-9]+$")
@length(min: 3, max: 100)
string DataRequestId

enum DataRequestFieldType {
    TEXT = "text"
    NUMBER = "number"
    BOOLEAN = "boolean"
    LIST_TEXT = "list<text>"
    OBJECT = "object"
    LIST_OBJECT = "list<object>"
}

enum WebhookImplementation {
    INLINE = "inline"
    INLINE_STATIC = "inline-static"
    EXTERNAL = "external"
    HOSTED = "hosted"
    MANAGED = "managed"
    FLOW_MODULE = "flow-module"
    MCP = "mcp"
}

enum WebhookMethod {
    DELETE = "DELETE"
    GET = "GET"
    PATCH = "PATCH"
    POST = "POST"
    PUT = "PUT"
}

// ============================================================================
// Request/Response Structures
// ============================================================================
structure ListDataRequestsRequest {
    @httpQuery("nextToken")
    nextToken: String

    @httpQuery("maxResults")
    @range(min: 1, max: 500)
    maxResults: Integer
}

structure ListDataRequestsResponse {
    @required
    items: DataRequestList

    nextToken: String
}

structure CreateDataRequestRequest {
    @required
    dataRequestId: DataRequestId

    @required
    type: DataRequestFieldType

    @required
    webhook: WebhookConfig

    requestSchema: Document

    responseSchema: Document

    sensitive: Boolean

    @length(max: 200)
    description: String

    metadata: DataRequestMetadata
}

structure GetDataRequestRequest {
    @required
    @httpLabel
    dataRequestIdentifier: DataRequestId
}

structure UpdateDataRequestRequest {
    @required
    @httpLabel
    dataRequestIdentifier: DataRequestId

    type: DataRequestFieldType

    webhook: WebhookConfig

    requestSchema: Document

    responseSchema: Document

    sensitive: Boolean

    @length(max: 200)
    description: String

    metadata: DataRequestMetadata
}

structure DeleteDataRequestRequest {
    @required
    @httpLabel
    dataRequestIdentifier: DataRequestId
}

// ============================================================================
// Resource Shapes
// ============================================================================
/// Full data request resource.
structure DataRequest {
    @required
    dataRequestId: DataRequestId

    @required
    type: DataRequestFieldType

    @required
    webhook: WebhookConfig

    requestSchema: Document

    responseSchema: Document

    sensitive: Boolean

    @length(max: 200)
    description: String

    metadata: DataRequestMetadata

    @required
    createdAt: DateTime

    @required
    updatedAt: DateTime

    updatedBy: String
}

structure DataRequestMetadata {
    @length(max: 512)
    path: String

    tags: DataRequestTagList
}

// ============================================================================
// Webhook Configuration
// ============================================================================
/// Webhook configuration for a data request.
structure WebhookConfig {
    @required
    implementation: WebhookImplementation

    method: WebhookMethod

    @length(max: 2048)
    url: String

    headers: WebhookHeaderList

    @length(max: 200000)
    code: String

    environments: Document

    provider: WebhookProvider

    flowModule: FlowModuleConfig

    mcp: WebhookMcpConfig

    sendContext: Boolean
}

structure FlowModuleConfig {
    @required
    @length(min: 1, max: 256)
    moduleId: String

    alias: String

    @range(min: 1)
    version: Long
}

structure WebhookMcpConfig {
    method: WebhookMethod

    @length(max: 2048)
    url: String

    headers: WebhookHeaderList

    environments: Document

    tools: McpToolList

    syncedAt: DateTime
}

structure McpTool {
    @required
    @pattern("^[A-Za-z0-9 _-]+$")
    @length(min: 1, max: 256)
    name: String

    enabled: Boolean

    requestSchema: Document

    responseSchema: Document

    annotations: Document
}

@length(max: 100)
list McpToolList {
    member: McpTool
}

structure WebhookHeader {
    @required
    @length(max: 128)
    key: String

    @required
    @length(max: 4096)
    value: String

    sensitive: Boolean

    dynamic: Boolean

    required: Boolean
}

structure WebhookProvider {
    providerId: String
    actionId: String
}

// ============================================================================
// Lists
// ============================================================================
list DataRequestList {
    member: DataRequest
}

list WebhookHeaderList {
    member: WebhookHeader
}

@length(max: 5)
list DataRequestTagList {
    member: DataRequestTag
}

@length(min: 1, max: 256)
string DataRequestTag
