// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
$version: "2"

namespace com.amazon.connect.acxd.sdk

// ============================================================================
// Operations — Downloads
// ============================================================================
@http(method: "GET", uri: "/sdk/downloads/{downloadIdentifier}")
@readonly
operation GetDownload {
    input: GetDownloadRequest
    output: GetDownloadResponse
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

// ============================================================================
// Operations — Scheduled Downloads
// ============================================================================
/// Lists all scheduled download configurations for the workspace, paginated.
@http(method: "GET", uri: "/sdk/scheduled-downloads")
@readonly
@paginated(inputToken: "nextToken", outputToken: "nextToken", items: "items", pageSize: "maxResults")
operation ListScheduledDownloads {
    input: ListScheduledDownloadsRequest
    output: ListScheduledDownloadsResponse
    errors: [
        ValidationException
        InternalServerException
    ]
}

/// Creates a new scheduled download configuration.
@http(method: "POST", uri: "/sdk/scheduled-downloads", code: 201)
operation CreateScheduledDownload {
    input: CreateScheduledDownloadRequest
    output: CreateScheduledDownloadResponse
    errors: [
        ValidationException
        ConflictException
        InternalServerException
    ]
}

/// Retrieves a single scheduled download configuration by ID.
@http(method: "GET", uri: "/sdk/scheduled-downloads/{scheduleIdentifier}")
@readonly
operation GetScheduledDownload {
    input: GetScheduledDownloadRequest
    output: ScheduledDownload
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

/// Updates an existing scheduled download configuration.
@http(method: "PATCH", uri: "/sdk/scheduled-downloads/{scheduleIdentifier}")
@idempotent
operation UpdateScheduledDownload {
    input: UpdateScheduledDownloadRequest
    output: UpdateScheduledDownloadResponse
    errors: [
        ResourceNotFoundException
        ValidationException
        InternalServerException
    ]
}

/// Deletes a scheduled download configuration and cleans up associated resources.
@http(method: "DELETE", uri: "/sdk/scheduled-downloads/{scheduleIdentifier}", code: 204)
@idempotent
operation DeleteScheduledDownload {
    input: DeleteScheduledDownloadRequest
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

// ============================================================================
// Custom Types — Downloads
// ============================================================================
@pattern("^[A-Za-z0-9 _-]+$")
@length(min: 1, max: 256)
string ScheduleName

/// Cron or rate expression for EventBridge (e.g., "cron(0 12 * * ? *)" or "rate(1 day)").
string ScheduleExpression

/// Destination configuration for a scheduled download. Exactly one of
/// awsS3Destination or sftpServerDestination must be provided.
union DownloadDestination {
    awsS3Destination: AwsS3Destination
    sftpServerDestination: SftpServerDestination
}

enum ScheduledDownloadType {
    CONVERSATION_HISTORY = "conversationHistory"
    CLUSTERED_MESSAGES = "clusteredMessages"
}

enum ScheduleState {
    ENABLED = "ENABLED"
    DISABLED = "DISABLED"
}

enum DownloadRegion {
    GLOBAL = "Global"
    EU = "EU"
}

enum BooleanString {
    TRUE = "true"
    FALSE = "false"
}

// ============================================================================
// Request/Response Structures — GetDownload
// ============================================================================
structure GetDownloadRequest {
    @required
    @httpLabel
    downloadIdentifier: UUIDv4
}

structure GetDownloadResponse {
    @required
    url: String
}

// ============================================================================
// Request/Response Structures — Scheduled Downloads
// ============================================================================
structure ListScheduledDownloadsRequest {
    @httpQuery("nextToken")
    nextToken: String

    @httpQuery("maxResults")
    @range(min: 1, max: 500)
    maxResults: Integer
}

structure ListScheduledDownloadsResponse {
    @required
    items: ScheduledDownloadSummaryList

    nextToken: String
}

structure CreateScheduledDownloadRequest {
    @required
    downloadDestination: DownloadDestination

    @required
    downloadType: ScheduledDownloadType

    @required
    scheduleExpression: ScheduleExpression

    @required
    durationInHours: DurationInHours

    scheduleName: ScheduleName

    scheduleExpressionTimezone: String

    filters: ConversationHistoryFilters

    state: ScheduleState
}

structure CreateScheduledDownloadResponse {
    @required
    scheduledDownload: ScheduledDownload

    bucketPolicyUpdate: String
}

structure GetScheduledDownloadRequest {
    @required
    @httpLabel
    scheduleIdentifier: UUIDv4
}

structure UpdateScheduledDownloadRequest {
    @required
    @httpLabel
    scheduleIdentifier: UUIDv4

    downloadDestination: DownloadDestination

    downloadType: ScheduledDownloadType

    scheduleExpression: ScheduleExpression

    durationInHours: DurationInHours

    scheduleName: ScheduleName

    scheduleExpressionTimezone: String

    filters: ConversationHistoryFilters

    state: ScheduleState
}

structure UpdateScheduledDownloadResponse {
    @required
    scheduledDownload: ScheduledDownload

    bucketPolicyUpdate: String
}

structure DeleteScheduledDownloadRequest {
    @required
    @httpLabel
    scheduleIdentifier: UUIDv4
}

// ============================================================================
// Filter Shapes
// ============================================================================
/// Filters for conversation history downloads.
structure ConversationHistoryFilters {
    region: DownloadRegion

    startTimestamp: String

    endTimestamp: String

    userId: String

    applicationId: UUIDv4

    @pattern("^[A-Za-z0-9-_.:]+$")
    @length(min: 5, max: 255)
    conversationId: String

    @pattern("^[A-Za-z]+$")
    @length(min: 3, max: 64)
    flowId: String

    @pattern("^[A-Za-z,]+$")
    @length(min: 3)
    flowIds: String

    languageCode: LanguageCode

    @length(min: 1, max: 2000)
    utterance: String

    @length(min: 1, max: 2000)
    search: String

    @pattern("^[A-Z_a-z0-9,]+$")
    tags: String

    excludeTrivials: BooleanString

    userEngagement: BooleanString

    sortBy: ConversationSortBy

    sortOrder: SortOrder

    includeSilence: Boolean

    includeEvaluations: BooleanString

    timezone: String
}

// ============================================================================
// Resource Shapes
// ============================================================================
/// Full scheduled download resource.
@mixin
structure _ScheduledDownloadBase {
    @required
    scheduleId: UUIDv4

    @required
    downloadDestination: DownloadDestination

    @required
    downloadType: ScheduledDownloadType

    @required
    scheduleExpression: ScheduleExpression

    @required
    durationInHours: DurationInHours

    scheduleName: ScheduleName

    scheduleExpressionTimezone: String

    filters: ConversationHistoryFilters

    state: ScheduleState

    updatedAt: DateTime
}

/// Full scheduled download resource.
structure ScheduledDownload with [_ScheduledDownloadBase] {
    contributors: Document
}

/// Summary shape for list responses (same fields minus contributors).
structure ScheduledDownloadSummary with [_ScheduledDownloadBase] {}

// ============================================================================
// Lists
// ============================================================================
list ScheduledDownloadSummaryList {
    member: ScheduledDownloadSummary
}
