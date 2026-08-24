// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
$version: "2"

namespace com.amazon.connect.acxd.sdk

// ============================================================================
// Operations — Logs
// ============================================================================
/// Queries logs from the workspace with time, search, and pagination filters.
@http(method: "POST", uri: "/sdk/logs/query")
operation QueryLogs {
    input: QueryLogsRequest
    output: QueryLogsResponse
    errors: [
        ValidationException
        InternalServerException
        ThrottlingException
    ]
}

// ============================================================================
// Enums — Logs
// ============================================================================
enum LogEventType {
    AUTO_ESCALATION_STATE = "AutoEscalationState"

    CHOICE_SELECTED = "ChoiceSelected"

    CONDITION_EVALUATED = "ConditionEvaluated"

    DEFAULT_FLOW_RETRIEVAL = "DefaultFlowRetrieval"

    FALLBACK_STATE = "FallbackState"

    FRUSTRATION_STATE = "FrustrationState"

    INCOMPREHENSION_STATE = "IncomprehensionState"

    FLOW_CAPTURE_STATE = "FlowCaptureState"

    FLOW_REDIRECTION = "FlowRedirection"

    LIFECYCLE_HOOK_INVOKED = "LifecycleHookInvoked"

    LIFECYCLE_HOOK_RESPONDED = "LifecycleHookResponded"

    NLU_REQUEST_RECEIVED = "NluRequestReceived"

    NLU_RESPONDED = "NluResponded"

    NODE_MET_ALL_CONDITIONS = "NodeMetAllConditions"

    NODE_TRAVERSAL = "NodeTraversal"

    REPEAT_STATE = "RepeatState"

    STATE_VALUES_EJECTED = "StateValuesEjected"

    DATA_REQUEST_RESOLUTION_FAILED = "DataRequestResolutionFailed"

    DATA_REQUESTS_REQUESTED = "DataRequestsRequested"

    DATA_REQUESTS_RETURNED = "DataRequestsReturned"

    RESPONSE_SKIPPED_AWAITING_USER_TURN = "ResponseSkippedAwaitingUserTurn"

    AGENT_STARTED = "AgentStarted"

    AGENT_ENDED = "AgentEnded"

    AGENTIC_TOOL_START = "AgenticToolStart"

    AGENTIC_TOOL_END = "AgenticToolEnd"

    AGENTIC_DATA_CAPTURE = "AgenticDataCapture"

    MODEL_START = "ModelStart"

    MODEL_END = "ModelEnd"

    MODEL_ERROR = "ModelError"

    MODEL_TIMEOUT = "ModelTimeout"

    TOOL_START = "ToolStart"

    TOOL_END = "ToolEnd"

    TOOL_HALLUCINATION = "ToolHallucination"

    HALLUCINATION_HEALED = "HallucinationHealed"

    GUARDRAILS_START = "GuardrailsStart"

    GUARDRAILS_END = "GuardrailsEnd"

    GUARDRAIL_RULE_EVALUATED = "GuardrailRuleEvaluated"

    GUARDRAIL_RULE_TRIGGERED = "GuardrailRuleTriggered"

    GENERATIVE_JOURNEY_STARTED = "GenerativeJourneyStarted"

    GENERATIVE_JOURNEY_SUCCEEDED = "GenerativeJourneySucceeded"

    GENERATIVE_JOURNEY_TIMEOUT = "GenerativeJourneyTimeout"

    GENERATIVE_JOURNEY_ZERO_TURN_COMPLETED = "GenerativeJourneyZeroTurnCompleted"

    GENERATIVE_RESPONSE = "GenerativeResponse"

    GENERATIVE_CONDITION_EVALUATED = "GenerativeConditionEvaluated"

    MULTIMODAL_STARTED = "MultimodalStarted"

    MULTIMODAL_ENDED = "MultimodalEnded"

    MULTIMODAL_STEP = "MultimodalStep"

    MULTIMODAL_ACTION_TRIGGERED = "MultimodalActionTriggered"

    KB_INVOKED = "KbInvoked"

    DOCUMENT_RETRIEVAL = "DocumentRetrieval"

    DATA_REQUEST_FAILURE = "DataRequestFailure"

    DATA_REQUEST_SUCCESS = "DataRequestSuccess"

    DATA_REQUEST_TIMEOUT = "DataRequestTimeout"

    ASYNC_DATA_REQUEST_INVOKED = "AsyncDataRequestInvoked"

    ASYNC_DATA_REQUEST_SUCCESS = "AsyncDataRequestSuccess"

    ASYNC_DATA_REQUEST_FAILURE = "AsyncDataRequestFailure"

    ASYNC_DATA_REQUEST_TIMEOUT = "AsyncDataRequestTimeout"

    DATA_TRANSFORMED = "DataTransformed"

    LOOP_ITERATION = "LoopIteration"

    INFINITE_LOOP = "InfiniteLoop"

    LIFECYCLE_HOOK_VALIDATION_FAILED = "LifecycleHookValidationFailed"

    WEBHOOK_RESPONSE_VALIDATION_FAILED = "WebhookResponseValidationFailed"

    SEND_ACTION_ATTEMPT = "SendActionAttempt"

    SEND_ACTION_SUCCESS = "SendActionSuccess"

    SEND_ACTION_ERROR = "SendActionError"

    REQUEST_OVERRIDDEN = "RequestOverridden"

    RESPONSE_OVERRIDDEN = "ResponseOverridden"

    CONTENT_NOT_FOUND = "ContentNotFound"

    USER_FEEDBACK = "UserFeedback"

    ESCALATION_STATE = "EscalationState"

    REDIRECTION = "Redirection"

    ERROR = "Error"

    DATA_REQUEST_RESOLUTION_EXCEPTION = "DataRequestResolutionException"

    DATA_REQUEST_RESOLUTION_TIMEOUT = "DataRequestResolutionTimeout"
}

// ============================================================================
// Custom Types — Logs
// ============================================================================
@length(max: 256)
string LogUserId

// ============================================================================
// Request/Response Structures — QueryLogs
// ============================================================================
structure QueryLogsRequest {
    @required
    timeFilter: LogTimeFilter

    searchFilter: LogSearchFilter

    sortOrder: SortOrder

    @range(min: 5, max: 100)
    maxResults: Integer

    nextToken: String
}

structure QueryLogsResponse {
    @required
    queryStatus: LogQueryStatus

    @required
    items: LogEntryList

    nextToken: String
}

// ============================================================================
// Filter Structures
// ============================================================================
union LogTimeFilter {
    relative: RelativeTimeFilter
    absolute: AbsoluteTimeFilter
}

structure RelativeTimeFilter {
    @required
    span: String
}

structure AbsoluteTimeFilter {
    @required
    startTimestamp: DateTime

    @required
    endTimestamp: DateTime
}

structure LogSearchFilter {
    applicationId: UUIDv4
    buildId: UUIDv4
    conversationId: ConversationId
    correlationId: UUIDv4
    deploymentId: UUIDv4
    languageCode: LanguageCode
    userId: LogUserId
    eventType: LogEventType
}

// ============================================================================
// Response Structures
// ============================================================================
structure LogQueryStatus {
    @required
    progressPercentage: Double

    @required
    cumulativeBytesScanned: Long

    @required
    cumulativeBytesMetered: Long
}

structure LogEntry {
    @required
    eventType: LogEventType

    @required
    eventTime: DateTime

    commonProperties: LogPropertyList

    eventProperties: LogPropertyList
}

structure LogProperty {
    @required
    key: String

    @required
    value: String
}

// ============================================================================
// Lists — Logs
// ============================================================================
list LogEntryList {
    member: LogEntry
}

list LogPropertyList {
    member: LogProperty
}
