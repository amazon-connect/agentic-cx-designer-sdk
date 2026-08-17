// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
$version: "2"

namespace com.amazon.connect.acxd.sdk

// ============================================================================
// Operations — Guardrails
// ============================================================================
/// Lists all guardrails for the workspace, paginated.
@http(method: "GET", uri: "/sdk/guardrails")
@readonly
@paginated(inputToken: "nextToken", outputToken: "nextToken", items: "items", pageSize: "maxResults")
operation ListGuardrails {
    input: ListGuardrailsRequest
    output: ListGuardrailsResponse
    errors: [
        ValidationException
        InternalServerException
    ]
}

/// Creates a new guardrail.
@http(method: "POST", uri: "/sdk/guardrails", code: 201)
operation CreateGuardrail {
    input: CreateGuardrailRequest
    output: Guardrail
    errors: [
        ValidationException
        ConflictException
        InternalServerException
    ]
}

/// Retrieves a single guardrail by ID.
@http(method: "GET", uri: "/sdk/guardrails/{guardrailIdentifier}")
@readonly
operation GetGuardrail {
    input: GetGuardrailRequest
    output: Guardrail
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

/// Updates an existing guardrail.
@http(method: "PATCH", uri: "/sdk/guardrails/{guardrailIdentifier}")
@idempotent
operation UpdateGuardrail {
    input: UpdateGuardrailRequest
    output: Guardrail
    errors: [
        ResourceNotFoundException
        ValidationException
        InternalServerException
    ]
}

/// Deletes a guardrail by ID.
@http(method: "DELETE", uri: "/sdk/guardrails/{guardrailIdentifier}", code: 204)
@idempotent
operation DeleteGuardrail {
    input: DeleteGuardrailRequest
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

/// Runs a test input through the guardrail's rules and returns processed output and violations.
@http(method: "POST", uri: "/sdk/guardrails/{guardrailIdentifier}/test")
operation TestGuardrail {
    input: TestGuardrailRequest
    output: TestGuardrailResponse
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

/// Lists historical guardrail trigger events with filter options.
@http(method: "GET", uri: "/sdk/guardrails/events")
@readonly
operation ListGuardrailEvents {
    input: ListGuardrailEventsRequest
    output: ListGuardrailEventsResponse
    errors: [
        ValidationException
        InternalServerException
    ]
}

// ============================================================================
// Custom Types — Guardrails
// ============================================================================
@pattern("^[A-Za-z0-9 ()_-]+$")
@length(min: 1, max: 100)
string GuardrailName

@pattern("^[ -~]*$")
@length(max: 100)
string GuardrailDescription

enum GuardrailTrigger {
    INPUT = "input"
    OUTPUT = "output"
}

enum DetectionMethod {
    REGEX = "regex"
    KEYWORD = "keyword"
    LLM_JUDGE = "llmJudge"
}

enum EnforcementAction {
    MASK = "mask"
    MODIFY = "modify"
    ROUTE = "route"
    FLAG = "flag"
}

enum FallbackBehaviorType {
    CONTINUE = "continue"
    ROUTE_TO_FLOW = "routeToFlow"
}

// ============================================================================
// Request/Response Structures — Guardrails CRUD
// ============================================================================
structure ListGuardrailsRequest {
    @httpQuery("nextToken")
    nextToken: String

    @httpQuery("maxResults")
    @range(min: 1, max: 500)
    maxResults: Integer
}

structure ListGuardrailsResponse {
    @required
    items: GuardrailList

    nextToken: String
}

structure CreateGuardrailRequest {
    @required
    name: GuardrailName

    @required
    rules: GuardrailRuleInputList

    @required
    trigger: GuardrailTrigger

    description: GuardrailDescription

    active: Boolean

    metadata: GuardrailMetadata

    fallbackBehavior: FallbackBehavior
}

structure GetGuardrailRequest {
    @required
    @httpLabel
    guardrailIdentifier: UUIDv4
}

structure UpdateGuardrailRequest {
    @required
    @httpLabel
    guardrailIdentifier: UUIDv4

    name: GuardrailName

    rules: GuardrailRuleInputList

    trigger: GuardrailTrigger

    description: GuardrailDescription

    active: Boolean

    metadata: GuardrailMetadata

    fallbackBehavior: FallbackBehavior
}

structure DeleteGuardrailRequest {
    @required
    @httpLabel
    guardrailIdentifier: UUIDv4
}

// ============================================================================
// Request/Response Structures — TestGuardrail
// ============================================================================
structure TestGuardrailRequest {
    @required
    @httpLabel
    guardrailIdentifier: UUIDv4

    @required
    @length(min: 1)
    input: String

    trigger: GuardrailTrigger
}

structure TestGuardrailResponse {
    @required
    input: String

    @required
    processedInput: String

    @required
    output: String

    @required
    blocked: Boolean

    terminalRuleId: String

    @required
    violations: GuardrailViolationList
}

// ============================================================================
// Request/Response Structures — ListGuardrailEvents
// ============================================================================
structure ListGuardrailEventsRequest {
    @required
    @httpQuery("startTimestamp")
    startTimestamp: String

    @required
    @httpQuery("endTimestamp")
    endTimestamp: String

    @httpQuery("region")
    region: DownloadRegion

    @httpQuery("guardrailIdentifier")
    guardrailIdentifier: UUIDv4

    @httpQuery("behaviorType")
    behaviorType: EnforcementAction

    @httpQuery("userId")
    @length(max: 255)
    userId: String

    @httpQuery("applicationId")
    applicationId: UUIDv4

    @httpQuery("conversationId")
    conversationId: String

    @httpQuery("languageCode")
    languageCode: LanguageCode

    @httpQuery("ruleId")
    ruleId: UUIDv4

    @httpQuery("sortBy")
    sortBy: GuardrailEventSortBy

    @httpQuery("sortOrder")
    sortOrder: SortOrder

    @httpQuery("timezone")
    timezone: String
}

structure ListGuardrailEventsResponse {
    @required
    items: GuardrailEventList
}

enum GuardrailEventSortBy {
    TIMESTAMP = "timestamp"
}

// ============================================================================
// Resource Shapes
// ============================================================================
/// Full guardrail resource.
structure Guardrail {
    @required
    guardrailId: UUIDv4

    @required
    name: GuardrailName

    @required
    rules: GuardrailRuleList

    trigger: GuardrailTrigger

    description: GuardrailDescription

    active: Boolean

    metadata: GuardrailMetadata

    fallbackBehavior: FallbackBehavior

    createdAt: DateTime

    updatedAt: DateTime

    updatedBy: String
}

structure GuardrailMetadata {
    @length(max: 512)
    path: String

    tags: GuardrailTagList
}

structure FallbackBehavior {
    type: FallbackBehaviorType
    flowId: String
}

// ============================================================================
// Rule Shapes
// ============================================================================
/// Rule as returned in responses (includes server-generated id).
structure GuardrailRule {
    @required
    id: UUIDv4

    @required
    @pattern("^[A-Za-z0-9 ()_-]+$")
    @length(max: 100)
    name: String

    @required
    detection: Detection

    @required
    enforcement: Enforcement

    @pattern("^[ -~]*$")
    @length(max: 100)
    description: String

    active: Boolean

    stateModifications: SimpleStateModificationList

    tags: AnalyticsTagList
}

/// Rule as provided in create/update requests (id is optional — server generates for new rules).
structure GuardrailRuleInput {
    id: UUIDv4

    @required
    @pattern("^[A-Za-z0-9 ()_-]+$")
    @length(max: 100)
    name: String

    @required
    detection: Detection

    @required
    enforcement: Enforcement

    @pattern("^[ -~]*$")
    @length(max: 100)
    description: String

    active: Boolean

    stateModifications: SimpleStateModificationList

    tags: AnalyticsTagList
}

structure Detection {
    @required
    method: DetectionMethod

    @length(max: 200)
    pattern: String

    keywords: KeywordList

    @length(max: 4000)
    prompt: String

    threshold: Float
}

structure Enforcement {
    @required
    action: EnforcementAction

    tags: EnforcementTagList

    behavior: EnforcementBehavior
}

/// Behavior configuration — fields depend on the enforcement action.
/// For "modify": set message or prompt (mutually exclusive), optionally flowId.
/// For "route": set flowId.
/// For "mask"/"flag": optionally set maskChar and maskText.
structure EnforcementBehavior {
    @length(max: 500)
    message: String

    @length(max: 1000)
    prompt: String

    flowId: String

    @length(max: 1)
    maskChar: String

    @length(max: 50)
    maskText: String
}

structure AnalyticsTag {
    @required
    @pattern("^[A-Za-z0-9-_]+$")
    label: String
}

// ============================================================================
// Guardrail Event Shape
// ============================================================================
structure GuardrailEvent {
    timestamp: String
    applicationId: UUIDv4
    conversationId: String
    correlationId: String
    userId: String
    languageCode: String
    guardrailId: UUIDv4
    guardrailName: String
    guardrailType: String
    behaviorType: String
    ruleId: UUIDv4
    ruleName: String
    ruleApplied: String
    ruleOutput: String
    originalRequest: String
    originalResponse: String
    nluRequest: String
    nluResponse: Document
    routedFlowId: String
    responseTime: Float
}

// ============================================================================
// Violation Shape
// ============================================================================
structure GuardrailViolation {
    ruleId: String
    ruleName: String
    tags: ViolationTagList
    action: EnforcementAction
    behavior: EnforcementBehavior
    metadata: ViolationMetadata
    latencyMs: Integer
}

/// Detection metadata explaining why the rule triggered.
structure ViolationMetadata {
    /// The regex pattern that matched (for regex detection).
    pattern: String

    /// The keyword that was found (for keyword detection).
    keyword: String

    /// The LLM's reasoning (for llmJudge detection).
    reason: String
}

// ============================================================================
// Lists
// ============================================================================
list GuardrailList {
    member: Guardrail
}

@length(max: 50)
list GuardrailRuleList {
    member: GuardrailRule
}

@length(max: 50)
list GuardrailRuleInputList {
    member: GuardrailRuleInput
}

@length(min: 1, max: 200)
list KeywordList {
    member: Keyword
}

@length(min: 1, max: 50)
string Keyword

list EnforcementTagList {
    member: String
}

list AnalyticsTagList {
    member: AnalyticsTag
}

list GuardrailEventList {
    member: GuardrailEvent
}

list GuardrailViolationList {
    member: GuardrailViolation
}

list ViolationTagList {
    member: String
}

@length(max: 5)
list GuardrailTagList {
    member: GuardrailTag
}

@length(min: 1, max: 256)
string GuardrailTag
