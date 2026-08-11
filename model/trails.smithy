// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
$version: "2"

namespace com.amazon.connect.acxd.sdk

// ============================================================================
// Operations — Trails
// ============================================================================
/// Submits a trail query with the given filters and returns a result ID for polling.
@http(method: "POST", uri: "/sdk/trails/query", code: 202)
operation StartTrailQuery {
    input: StartTrailQueryRequest
    output: StartTrailQueryResponse
    errors: [
        ValidationException
        InternalServerException
        ThrottlingException
    ]
}

/// Retrieves the results of a previously submitted trail query by result ID.
@http(method: "GET", uri: "/sdk/trails/results/{resultId}")
@readonly
operation GetTrailQueryResults {
    input: GetTrailQueryResultsRequest
    output: GetTrailQueryResultsResponse
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
        ThrottlingException
    ]
}

// ============================================================================
// Enums — Trails
// ============================================================================
enum TrailQueryStatus {
    IN_PROGRESS = "IN_PROGRESS"
    SUCCEEDED = "SUCCEEDED"
    FAILED = "FAILED"
    CANCELLED = "CANCELLED"
}

enum TrailEventType {
    WRITE = "WRITE"
    DELETE = "DELETE"
}

enum TrailEventName {
    ACTION_CREATE = "ActionCreate"
    ACTION_DELETE = "ActionDelete"
    ACTION_UPDATE = "ActionUpdate"
    ANALYTICS_MONITOR_CREATE = "AnalyticsMonitorCreate"
    ANALYTICS_SUBSCRIPTION_CREATE = "AnalyticsSubscriptionCreate"
    CLUSTERS_MONITOR_CREATE = "ClustersMonitorCreate"
    SUBSCRIPTION_DELETE = "SubscriptionDelete"
    MONITOR_UPDATE = "MonitorUpdate"
    NOTIFICATION_ALERT_DELETE = "NotificationAlertDelete"
    NOTIFICATION_ALERT_UPDATE = "NotificationAlertUpdate"
    DASHBOARD_CREATE = "DashboardCreate"
    DASHBOARD_DELETE = "DashboardDelete"
    DASHBOARD_UPDATE = "DashboardUpdate"
    APPLICATION_CREATE = "ApplicationCreate"
    APPLICATION_DELETE = "ApplicationDelete"
    APPLICATION_UPDATE = "ApplicationUpdate"
    BUILD_CREATE = "BuildCreate"
    BUILD_UPDATE = "BuildUpdate"
    DEPLOYMENT_CREATE = "DeploymentCreate"
    DEPLOYMENT_DELETE = "DeploymentDelete"
    DEPLOYMENT_UPDATE = "DeploymentUpdate"
    DATA_REQUEST_CREATE = "DataRequestCreate"
    DATA_REQUEST_DELETE = "DataRequestDelete"
    DATA_REQUEST_UPDATE = "DataRequestUpdate"
    HISTORY_TAB_CREATE = "HistoryTabCreate"
    HISTORY_TAB_DELETE = "HistoryTabDelete"
    HISTORY_TAB_UPDATE = "HistoryTabUpdate"
    INTEGRATION_CREATE = "IntegrationCreate"
    INTEGRATION_DELETE = "IntegrationDelete"
    INTEGRATION_UPDATE = "IntegrationUpdate"
    FLOW_CLONE_CREATE = "FlowCloneCreate"
    FLOW_CREATE = "FlowCreate"
    FLOW_DELETE = "FlowDelete"
    FLOW_UPDATE = "FlowUpdate"
    TRANSLATE_CONTENT = "TranslateContent"
    APPLY_UPLOAD = "ApplyUpload"
    SUPPORTED_LANGUAGES_UPDATE = "SupportedLanguagesUpdate"
    UPDATE_RESOURCE_SUPPORTED_LANGUAGES = "UpdateResourceSupportedLanguages"
    REQUEST_TRANSLATION = "RequestTranslation"
    JOURNEY_BUILD_CREATE = "JourneyBuildCreate"
    JOURNEY_BUILD_DELETE = "JourneyBuildDelete"
    JOURNEY_CREATE = "JourneyCreate"
    JOURNEY_DELETE = "JourneyDelete"
    JOURNEY_DEPLOYMENT_CREATE = "JourneyDeploymentCreate"
    JOURNEY_DEPLOYMENT_DELETE = "JourneyDeploymentDelete"
    JOURNEY_DEPLOYMENT_UPDATE = "JourneyDeploymentUpdate"
    JOURNEY_UPDATE = "JourneyUpdate"
    KNOWLEDGE_BASE_ARTICLE_CREATE = "KnowledgeBaseArticleCreate"
    KNOWLEDGE_BASE_ARTICLE_DELETE = "KnowledgeBaseArticleDelete"
    KNOWLEDGE_BASE_ARTICLE_UPDATE = "KnowledgeBaseArticleUpdate"
    KNOWLEDGE_BASE_CLONE_CREATE = "KnowledgeBaseCloneCreate"
    KNOWLEDGE_BASE_CREATE = "KnowledgeBaseCreate"
    KNOWLEDGE_BASE_DELETE = "KnowledgeBaseDelete"
    KNOWLEDGE_BASE_UPDATE = "KnowledgeBaseUpdate"
    LIFECYCLE_HOOK_CREATE = "LifecycleHookCreate"
    LIFECYCLE_HOOK_DELETE = "LifecycleHookDelete"
    LIFECYCLE_HOOK_UPDATE = "LifecycleHookUpdate"
    MODALITY_CREATE = "ModalityCreate"
    MODALITY_DELETE = "ModalityDelete"
    MODALITY_UPDATE = "ModalityUpdate"
    SECRET_CREATE = "SecretCreate"
    SECRET_DELETE = "SecretDelete"
    SECRET_UPDATE = "SecretUpdate"
    SLOT_TYPE_CREATE = "SlotTypeCreate"
    SLOT_TYPE_DELETE = "SlotTypeDelete"
    SLOT_TYPE_UPDATE = "SlotTypeUpdate"
    TEST_CREATE = "TestCreate"
    TEST_DELETE = "TestDelete"
    TEST_EXECUTION_CREATE = "TestExecutionCreate"
    TEST_UPDATE = "TestUpdate"
    ANALYTICS_TAGS_UPDATE = "AnalyticsTagsUpdate"
    CONTEXT_VARIABLES_UPDATE = "ContextVariablesUpdate"
    BATCH_DELETE = "BatchDelete"
    DELETE_UPLOAD = "DeleteUpload"
    DOWNLOAD_FILE = "DownloadFile"
    DOWNLOAD_CONVERSATIONS = "DownloadConversations"
    UNKNOWN_MESSAGES_UPDATE = "UnknownMessagesUpdate"
    REQUEST_DOWNLOAD = "RequestDownload"
}

// ============================================================================
// Custom Types — Trails
// ============================================================================
@pattern("^[a-zA-Z0-9]*$")
@length(min: 24, max: 30)
string TrailPrincipalId

// ============================================================================
// Request/Response Structures — QueryTrails
// ============================================================================
structure StartTrailQueryRequest {
    @required
    startTimestamp: DateTime

    @required
    endTimestamp: DateTime

    eventType: TrailEventType

    eventName: TrailEventName

    principalId: TrailPrincipalId

    principalEmail: String

    sourceIpAddress: String

    @range(min: 0, max: 100)
    page: Integer

    @range(min: 1, max: 100)
    size: Integer
}

structure StartTrailQueryResponse {
    @required
    resultId: String
}

// ============================================================================
// Request/Response Structures — GetTrailResults
// ============================================================================
structure GetTrailQueryResultsRequest {
    @required
    @httpLabel
    resultId: String
}

structure GetTrailQueryResultsResponse {
    @required
    status: TrailQueryStatus

    @required
    items: TrailEventList
}

// ============================================================================
// Resource Shapes — Trail Events
// ============================================================================
structure TrailEvent {
    eventVersion: String
    eventTime: String
    eventSource: String
    eventName: String
    eventType: String
    sourceIpAddress: String
    userAgent: String
    requestId: String
    requestParameters: String
    responseElements: String
    errorCode: String
    errorMessage: String
    userType: String
    userId: String
    email: String
    userName: String
    tier: String
}

// ============================================================================
// Lists — Trails
// ============================================================================
list TrailEventList {
    member: TrailEvent
}
