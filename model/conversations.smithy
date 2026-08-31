// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
$version: "2"

namespace com.amazon.connect.acxd.sdk

// ============================================================================
// Operations — Conversations
// ============================================================================
/// Fetches a single conversation's messages by ID. Optionally includes evaluation results.
@http(method: "GET", uri: "/sdk/conversations/{conversationIdentifier}")
@readonly
operation GetConversation {
    input: GetConversationRequest
    output: Conversation
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

/// Lists conversation transcripts with filters, paginated.
@http(method: "GET", uri: "/sdk/conversations")
@readonly
@paginated(inputToken: "nextToken", outputToken: "nextToken", items: "items", pageSize: "maxResults")
operation ListConversations {
    input: ListConversationsRequest
    output: ListConversationsResponse
    errors: [
        ValidationException
        InternalServerException
    ]
}

// ============================================================================
// Request/Response Structures — GetConversation
// ============================================================================
structure GetConversationRequest {
    @required
    @httpLabel
    conversationIdentifier: UUIDv4

    @httpQuery("includeSilence")
    includeSilence: Boolean

    @httpQuery("includeEvaluations")
    includeEvaluations: BooleanString
}

// ============================================================================
// Request/Response Structures — ListConversations
// ============================================================================
structure ListConversationsRequest {
    @required
    @httpQuery("startTimestamp")
    startTimestamp: String

    @required
    @httpQuery("endTimestamp")
    endTimestamp: String

    @httpQuery("userId")
    userId: String

    @httpQuery("applicationId")
    applicationId: UUIDv4

    @httpQuery("conversationIdentifier")
    conversationIdentifier: UUIDv4

    @httpQuery("flowId")
    @pattern("^[A-Za-z]+$")
    @length(min: 3, max: 64)
    flowId: String

    @httpQuery("flowIds")
    @pattern("^[A-Za-z,]+$")
    @length(min: 3)
    flowIds: String

    @httpQuery("languageCode")
    languageCode: LanguageCode

    @httpQuery("utterance")
    @length(min: 1, max: 2000)
    utterance: String

    @httpQuery("search")
    @length(min: 1, max: 2000)
    search: String

    @httpQuery("analyticsTags")
    @pattern("^[A-Z_a-z0-9,]+$")
    @length(min: 1)
    analyticsTags: String

    @httpQuery("excludeTrivials")
    excludeTrivials: BooleanString

    @httpQuery("userEngagement")
    userEngagement: BooleanString

    @httpQuery("sortBy")
    sortBy: ConversationSortBy

    @httpQuery("sortOrder")
    sortOrder: SortOrder

    @httpQuery("includeSilence")
    includeSilence: Boolean

    @httpQuery("includeEvaluations")
    includeEvaluations: BooleanString

    @httpQuery("timezone")
    timezone: String

    @httpQuery("nextToken")
    nextToken: String

    @httpQuery("maxResults")
    @range(min: 10, max: 300)
    maxResults: Integer
}

structure ListConversationsResponse {
    @required
    items: ConversationSummaryList

    nextToken: String
}

// ============================================================================
// Resource Shapes — Conversation
// ============================================================================
/// Full conversation with messages — returned by GetConversation.
structure Conversation {
    @required
    conversationId: UUIDv4

    @required
    timestamp: String

    userId: SensitiveString

    applicationId: UUIDv4

    duration: Float

    flowIds: StringList

    analyticsTags: StringList

    responseTime: Float

    @required
    messages: ConversationMessageList

    evaluationResults: EvaluationResultList
}

/// Summary shape for list responses.
structure ConversationSummary {
    @required
    firstTimestamp: String

    applicationId: UUIDv4

    @required
    conversationId: UUIDv4

    userId: SensitiveString

    firstUtterance: SensitiveString

    flowIds: StringList

    elapsedSeconds: Integer

    analyticsTags: StringList

    avgSentimentScore: Float

    avgResponseTime: Float

    evaluationResults: EvaluationResultList
}

// ============================================================================
// Message Shape
// ============================================================================
structure ConversationMessage {
    @required
    isApplication: Boolean

    text: SensitiveString

    timestamp: String

    correlationId: String

    nodeId: String

    flowId: String

    isEscalation: Boolean

    isIncomprehension: Boolean

    isStructured: Boolean

    analyticsTags: StringList

    type: String
}

// ============================================================================
// Evaluation Results
// ============================================================================
structure EvaluationResult {
    evaluationId: String
    evaluationName: String
    score: Float
    result: String
    feedback: String
}

// ============================================================================
// Lists
// ============================================================================
list ConversationSummaryList {
    member: ConversationSummary
}

list ConversationMessageList {
    member: ConversationMessage
}

list EvaluationResultList {
    member: EvaluationResult
}
