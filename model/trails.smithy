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
    ANALYTICS_TAGS_BATCH_UPDATE = "AnalyticsTagsBatchUpdate"
    ANALYTICS_TAGS_CREATE = "AnalyticsTagsCreate"
    ANALYTICS_TAGS_DELETE = "AnalyticsTagsDelete"
    ANALYTICS_TAGS_UPDATE = "AnalyticsTagsUpdate"
    APPLICATION_BATCH_UPDATE = "ApplicationBatchUpdate"
    APPLICATION_CREATE = "ApplicationCreate"
    APPLICATION_DELETE = "ApplicationDelete"
    APPLICATION_UPDATE = "ApplicationUpdate"
    APPLY_UPLOAD = "ApplyUpload"
    BUILD_CREATE = "BuildCreate"
    BUILD_UPDATE = "BuildUpdate"
    CONTEXT_VARIABLES_CREATE = "ContextVariablesCreate"
    CONTEXT_VARIABLES_DELETE = "ContextVariablesDelete"
    CONTEXT_VARIABLES_UPDATE = "ContextVariablesUpdate"
    CONVERSATION_FLOW_BATCH_UPDATE = "ConversationFlowBatchUpdate"
    CONVERSATION_FLOW_CLONE_CREATE = "ConversationFlowCloneCreate"
    CONVERSATION_FLOW_CREATE = "ConversationFlowCreate"
    CONVERSATION_FLOW_DELETE = "ConversationFlowDelete"
    CONVERSATION_FLOW_UPDATE = "ConversationFlowUpdate"
    DASHBOARD_CREATE = "DashboardCreate"
    DASHBOARD_DELETE = "DashboardDelete"
    DASHBOARD_UPDATE = "DashboardUpdate"
    DATA_REQUEST_BATCH_UPDATE = "DataRequestBatchUpdate"
    DATA_REQUEST_CREATE = "DataRequestCreate"
    DATA_REQUEST_DELETE = "DataRequestDelete"
    DATA_REQUEST_UPDATE = "DataRequestUpdate"
    DELETE_UPLOAD = "DeleteUpload"
    DEPLOYMENT_CREATE = "DeploymentCreate"
    DEPLOYMENT_DELETE = "DeploymentDelete"
    DEPLOYMENT_UPDATE = "DeploymentUpdate"
    DOWNLOAD_FILE = "DownloadFile"
    GUARDRAIL_BATCH_UPDATE = "GuardrailBatchUpdate"
    GUARDRAIL_CREATE = "GuardrailCreate"
    GUARDRAIL_DELETE = "GuardrailDelete"
    GUARDRAIL_UPDATE = "GuardrailUpdate"
    KNOWLEDGE_BASE_ARTICLE_CREATE = "KnowledgeBaseArticleCreate"
    KNOWLEDGE_BASE_ARTICLE_DELETE = "KnowledgeBaseArticleDelete"
    KNOWLEDGE_BASE_ARTICLE_UPDATE = "KnowledgeBaseArticleUpdate"
    KNOWLEDGE_BASE_BATCH_UPDATE = "KnowledgeBaseBatchUpdate"
    KNOWLEDGE_BASE_CLONE_CREATE = "KnowledgeBaseCloneCreate"
    KNOWLEDGE_BASE_CREATE = "KnowledgeBaseCreate"
    KNOWLEDGE_BASE_DELETE = "KnowledgeBaseDelete"
    KNOWLEDGE_BASE_DOCUMENT_DELETE = "KnowledgeBaseDocumentDelete"
    KNOWLEDGE_BASE_DOCUMENT_UPLOAD = "KnowledgeBaseDocumentUpload"
    KNOWLEDGE_BASE_PUBLISH = "KnowledgeBasePublish"
    KNOWLEDGE_BASE_UPDATE = "KnowledgeBaseUpdate"
    LIVE_SYNC_SCRIPT_BATCH_UPDATE = "LiveSyncScriptBatchUpdate"
    LIVE_SYNC_SCRIPT_BUILD_CREATE = "LiveSyncScriptBuildCreate"
    LIVE_SYNC_SCRIPT_BUILD_DELETE = "LiveSyncScriptBuildDelete"
    LIVE_SYNC_SCRIPT_CREATE = "LiveSyncScriptCreate"
    LIVE_SYNC_SCRIPT_DELETE = "LiveSyncScriptDelete"
    LIVE_SYNC_SCRIPT_DEPLOYMENT_CREATE = "LiveSyncScriptDeploymentCreate"
    LIVE_SYNC_SCRIPT_DEPLOYMENT_DELETE = "LiveSyncScriptDeploymentDelete"
    LIVE_SYNC_SCRIPT_DEPLOYMENT_UPDATE = "LiveSyncScriptDeploymentUpdate"
    LIVE_SYNC_SCRIPT_UPDATE = "LiveSyncScriptUpdate"
    MODALITY_BATCH_UPDATE = "ModalityBatchUpdate"
    MODALITY_CREATE = "ModalityCreate"
    MODALITY_DELETE = "ModalityDelete"
    MODALITY_UPDATE = "ModalityUpdate"
    REQUEST_DOWNLOAD = "RequestDownload"
    REQUEST_TRANSLATION = "RequestTranslation"
    REQUEST_TRANSLATION_EXPORT = "RequestTranslationExport"
    RESOURCE_FOLDERS_UPDATE = "ResourceFoldersUpdate"
    RESOURCE_TAGS_UPDATE = "ResourceTagsUpdate"
    SECRET_BATCH_UPDATE = "SecretBatchUpdate"
    SECRET_CREATE = "SecretCreate"
    SECRET_DELETE = "SecretDelete"
    SECRET_UPDATE = "SecretUpdate"
    SLOT_BATCH_UPDATE = "SlotBatchUpdate"
    SLOT_CREATE = "SlotCreate"
    SLOT_DELETE = "SlotDelete"
    SLOT_UPDATE = "SlotUpdate"
    SUPPORTED_LANGUAGES_UPDATE = "SupportedLanguagesUpdate"
    TEST_CREATE = "TestCreate"
    TEST_DELETE = "TestDelete"
    TEST_EXECUTION_CREATE = "TestExecutionCreate"
    TEST_UPDATE = "TestUpdate"
    TIMEZONE_UPDATE = "TimezoneUpdate"
    TRANSLATE_CONTENT = "TranslateContent"
    UPDATE_RESOURCE_SUPPORTED_LANGUAGES = "UpdateResourceSupportedLanguages"
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
