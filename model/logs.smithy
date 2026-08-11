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
    CHOICE_AUTOTRAVERSED = "ChoiceAutotraversed"
    CHOICE_SELECTED = "ChoiceSelected"
    CONDITION_EVALUATED = "ConditionEvaluated"
    CONTEXT_VARIABLES_MODIFIED = "ContextVariablesModified"
    CONVERSATION_ENDED = "ConversationEnded"
    CONVERSATION_ESCALATED = "ConversationEscalated"
    CONVERSATION_STARTED = "ConversationStarted"
    DEFAULT_FLOW_RETRIEVAL = "DefaultFlowRetrieval"
    EXTERNAL_PROCESSING_COMPLETED = "ExternalProcessingCompleted"
    EXTERNAL_PROCESSING_HOOK_INVOKED = "ExternalProcessingHookInvoked"
    EXTERNAL_PROCESSING_HOOK_RESPONDED = "ExternalProcessingHookResponded"
    EXTERNAL_PROCESSING_STATUS_UPDATED = "ExternalProcessingStatusUpdated"
    FALLBACK_STATE = "FallbackState"
    FRUSTRATION_STATE = "FrustrationState"
    INCOMPREHENSION_STATE = "IncomprehensionState"
    FLOW_CAPTURE_STATE = "FlowCaptureState"
    FLOW_REDIRECTION = "FlowRedirection"
    LIFECYCLE_HOOK_INVOKED = "LifecycleHookInvoked"
    LIFECYCLE_HOOK_RESPONDED = "LifecycleHookResponded"
    NLP_INVOKED = "NlpInvoked"
    NLP_RESPONDED = "NlpResponded"
    NLU_REQUEST_RECEIVED = "NluRequestReceived"
    NLU_RESPONDED = "NluResponded"
    NODE_MET_ALL_CONDITIONS = "NodeMetAllConditions"
    NODE_TRAVERSAL = "NodeTraversal"
    REPEAT_STATE = "RepeatState"
    STATE_CREATED = "StateCreated"
    STATE_RETRIEVED_FROM_CACHE = "StateRetrievedFromCache"
    STATE_VALUES_EJECTED = "StateValuesEjected"
    SUBTREE_TRAVERSAL = "SubtreeTraversal"
    DATA_REQUEST_RESOLUTION_FAILED = "DataRequestResolutionFailed"
    DATA_REQUESTS_REQUESTED = "DataRequestsRequested"
    DATA_REQUESTS_RETURNED = "DataRequestsReturned"
    WAIT_STATE = "WaitState"
    RESPONSE_SKIPPED_AWAITING_USER_TURN = "ResponseSkippedAwaitingUserTurn"
}

enum LogRegion {
    GLOBAL = "Global"
    EU = "EU"
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

    region: LogRegion

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
