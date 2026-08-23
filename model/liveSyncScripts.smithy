// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
$version: "2"

namespace com.amazon.connect.acxd.sdk

// ============================================================================
// Operations — Live Sync Scripts (Core CRUD)
//
// A LiveSyncScript is the SDK-facing name for the internal "Journey" resource.
// The script body is carried as an opaque `steps` document — its detailed shape
// is validated server-side and is not part of the SDK's typed surface.
// ============================================================================
@http(method: "GET", uri: "/sdk/live-sync-scripts")
@readonly
@paginated(inputToken: "nextToken", outputToken: "nextToken", items: "items", pageSize: "maxResults")
operation ListLiveSyncScripts {
    input: ListLiveSyncScriptsRequest
    output: ListLiveSyncScriptsResponse
    errors: [
        ValidationException
        InternalServerException
    ]
}

@http(method: "POST", uri: "/sdk/live-sync-scripts", code: 201)
operation CreateLiveSyncScript {
    input: CreateLiveSyncScriptRequest
    output: LiveSyncScript
    errors: [
        ValidationException
        ConflictException
        InternalServerException
    ]
}

@http(method: "GET", uri: "/sdk/live-sync-scripts/{liveSyncScriptIdentifier}")
@readonly
operation GetLiveSyncScript {
    input: GetLiveSyncScriptRequest
    output: LiveSyncScript
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

@http(method: "PATCH", uri: "/sdk/live-sync-scripts/{liveSyncScriptIdentifier}")
@idempotent
operation UpdateLiveSyncScript {
    input: UpdateLiveSyncScriptRequest
    output: LiveSyncScript
    errors: [
        ResourceNotFoundException
        ValidationException
        InternalServerException
    ]
}

@http(method: "DELETE", uri: "/sdk/live-sync-scripts/{liveSyncScriptIdentifier}", code: 204)
@idempotent
operation DeleteLiveSyncScript {
    input: DeleteLiveSyncScriptRequest
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

// ============================================================================
// Operations — Live Sync Script Builds
// ============================================================================
@http(method: "GET", uri: "/sdk/live-sync-scripts/{liveSyncScriptIdentifier}/builds")
@readonly
@paginated(inputToken: "nextToken", outputToken: "nextToken", items: "items", pageSize: "maxResults")
operation ListLiveSyncScriptBuilds {
    input: ListLiveSyncScriptBuildsRequest
    output: ListLiveSyncScriptBuildsResponse
    errors: [
        ResourceNotFoundException
        ValidationException
        InternalServerException
    ]
}

@http(method: "POST", uri: "/sdk/live-sync-scripts/{liveSyncScriptIdentifier}/builds", code: 201)
operation CreateLiveSyncScriptBuild {
    input: CreateLiveSyncScriptBuildRequest
    output: LiveSyncScriptBuild
    errors: [
        ResourceNotFoundException
        ValidationException
        InternalServerException
    ]
}

@http(method: "GET", uri: "/sdk/live-sync-scripts/{liveSyncScriptIdentifier}/builds/{buildIdentifier}")
@readonly
operation GetLiveSyncScriptBuild {
    input: GetLiveSyncScriptBuildRequest
    output: LiveSyncScriptBuild
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

// ============================================================================
// Operations — Live Sync Script Deployments
// ============================================================================
@http(method: "GET", uri: "/sdk/live-sync-scripts/{liveSyncScriptIdentifier}/deployments")
@readonly
@paginated(inputToken: "nextToken", outputToken: "nextToken", items: "items", pageSize: "maxResults")
operation ListLiveSyncScriptDeployments {
    input: ListLiveSyncScriptDeploymentsRequest
    output: ListLiveSyncScriptDeploymentsResponse
    errors: [
        ResourceNotFoundException
        ValidationException
        InternalServerException
    ]
}

@http(method: "POST", uri: "/sdk/live-sync-scripts/{liveSyncScriptIdentifier}/deployments", code: 201)
operation CreateLiveSyncScriptDeployment {
    input: CreateLiveSyncScriptDeploymentRequest
    output: LiveSyncScriptDeployment
    errors: [
        ResourceNotFoundException
        ValidationException
        InternalServerException
    ]
}

@http(method: "GET", uri: "/sdk/live-sync-scripts/{liveSyncScriptIdentifier}/deployments/{deploymentIdentifier}")
@readonly
operation GetLiveSyncScriptDeployment {
    input: GetLiveSyncScriptDeploymentRequest
    output: LiveSyncScriptDeployment
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

@http(method: "PATCH", uri: "/sdk/live-sync-scripts/{liveSyncScriptIdentifier}/deployments/{deploymentIdentifier}")
@idempotent
operation UpdateLiveSyncScriptDeployment {
    input: UpdateLiveSyncScriptDeploymentRequest
    output: LiveSyncScriptDeployment
    errors: [
        ResourceNotFoundException
        ValidationException
        InternalServerException
    ]
}

@http(
    method: "DELETE"
    uri: "/sdk/live-sync-scripts/{liveSyncScriptIdentifier}/deployments/{deploymentIdentifier}"
    code: 204
)
@idempotent
operation DeleteLiveSyncScriptDeployment {
    input: DeleteLiveSyncScriptDeploymentRequest
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

// ============================================================================
// Custom Types — Live Sync Scripts
// ============================================================================
@pattern("^[A-Za-z0-9 _-]+$")
@length(min: 1, max: 100)
string LiveSyncScriptName

@pattern("^[ -~]*$")
@length(max: 200)
string LiveSyncScriptDescription

// ============================================================================
// Request/Response Structures — Core CRUD
// ============================================================================
structure ListLiveSyncScriptsRequest {
    @httpQuery("nextToken")
    nextToken: String

    @httpQuery("maxResults")
    @range(min: 1, max: 500)
    maxResults: Integer
}

structure ListLiveSyncScriptsResponse {
    @required
    items: LiveSyncScriptSummaryList

    nextToken: String
}

structure CreateLiveSyncScriptRequest {
    @required
    name: LiveSyncScriptName

    @required
    steps: LiveSyncScriptStepList

    description: LiveSyncScriptDescription

    metadata: LiveSyncScriptMetadata
}

structure GetLiveSyncScriptRequest {
    @required
    @httpLabel
    liveSyncScriptIdentifier: UUIDv4
}

structure UpdateLiveSyncScriptRequest {
    @required
    @httpLabel
    liveSyncScriptIdentifier: UUIDv4

    name: LiveSyncScriptName

    steps: LiveSyncScriptStepList

    description: LiveSyncScriptDescription

    metadata: LiveSyncScriptMetadata
}

structure DeleteLiveSyncScriptRequest {
    @required
    @httpLabel
    liveSyncScriptIdentifier: UUIDv4
}

// ============================================================================
// Request/Response Structures — Builds
// ============================================================================
structure ListLiveSyncScriptBuildsRequest {
    @required
    @httpLabel
    liveSyncScriptIdentifier: UUIDv4

    @httpQuery("nextToken")
    nextToken: String

    @httpQuery("maxResults")
    @range(min: 1, max: 500)
    maxResults: Integer
}

structure ListLiveSyncScriptBuildsResponse {
    @required
    items: LiveSyncScriptBuildList

    nextToken: String
}

structure CreateLiveSyncScriptBuildRequest {
    @required
    @httpLabel
    liveSyncScriptIdentifier: UUIDv4

    version: BuildVersion

    description: LiveSyncScriptDescription

    languageSettings: LanguageSettingList
}

structure GetLiveSyncScriptBuildRequest {
    @required
    @httpLabel
    liveSyncScriptIdentifier: UUIDv4

    @required
    @httpLabel
    buildIdentifier: UUIDv4
}

// ============================================================================
// Request/Response Structures — Deployments
// ============================================================================
structure ListLiveSyncScriptDeploymentsRequest {
    @required
    @httpLabel
    liveSyncScriptIdentifier: UUIDv4

    @httpQuery("nextToken")
    nextToken: String

    @httpQuery("maxResults")
    @range(min: 1, max: 500)
    maxResults: Integer
}

structure ListLiveSyncScriptDeploymentsResponse {
    @required
    items: LiveSyncScriptDeploymentList

    nextToken: String
}

structure CreateLiveSyncScriptDeploymentRequest {
    @required
    @httpLabel
    liveSyncScriptIdentifier: UUIDv4

    @required
    buildIdentifier: UUIDv4

    // Server requires a version on deployment ("version is required" otherwise).
    @required
    version: BuildVersion

    description: LiveSyncScriptDescription

    environment: DeploymentEnvironment

    languageCodes: LanguageCodeList

    analyticsTags: AnalyticsTagReferenceList
}

structure GetLiveSyncScriptDeploymentRequest {
    @required
    @httpLabel
    liveSyncScriptIdentifier: UUIDv4

    @required
    @httpLabel
    deploymentIdentifier: UUIDv4
}

structure UpdateLiveSyncScriptDeploymentRequest {
    @required
    @httpLabel
    liveSyncScriptIdentifier: UUIDv4

    @required
    @httpLabel
    deploymentIdentifier: UUIDv4

    @required
    buildIdentifier: UUIDv4

    description: LiveSyncScriptDescription

    environment: DeploymentEnvironment

    languageCodes: LanguageCodeList

    analyticsTags: AnalyticsTagReferenceList
}

structure DeleteLiveSyncScriptDeploymentRequest {
    @required
    @httpLabel
    liveSyncScriptIdentifier: UUIDv4

    @required
    @httpLabel
    deploymentIdentifier: UUIDv4
}

// ============================================================================
// Resource Shapes
// ============================================================================
/// Full Live Sync Script resource — returned by Create, Get, Update.
structure LiveSyncScript {
    @required
    liveSyncScriptId: UUIDv4

    @required
    name: LiveSyncScriptName

    @required
    steps: LiveSyncScriptStepList

    description: LiveSyncScriptDescription

    metadata: LiveSyncScriptMetadata

    apiKey: SensitiveString

    @required
    createdAt: DateTime

    @required
    updatedAt: DateTime

    updatedBy: String
}

/// Summary shape for list responses (excludes the steps body and api key).
structure LiveSyncScriptSummary {
    @required
    liveSyncScriptId: UUIDv4

    @required
    name: LiveSyncScriptName

    description: LiveSyncScriptDescription

    metadata: LiveSyncScriptMetadata

    @required
    createdAt: DateTime

    @required
    updatedAt: DateTime
}

structure LiveSyncScriptBuild {
    @required
    buildId: UUIDv4

    @required
    liveSyncScriptId: UUIDv4

    @required
    @length(max: 64)
    status: String

    description: LiveSyncScriptDescription

    languageSettings: LanguageSettingList

    @required
    createdAt: DateTime

    @required
    updatedAt: DateTime

    updatedBy: String
}

structure LiveSyncScriptDeployment {
    @required
    deploymentId: UUIDv4

    @required
    liveSyncScriptId: UUIDv4

    @required
    buildId: UUIDv4

    description: LiveSyncScriptDescription

    deploymentStatus: String

    environment: DeploymentEnvironment

    languageCodes: LanguageCodeList

    analyticsTags: AnalyticsTagReferenceList

    @required
    createdAt: DateTime

    @required
    updatedAt: DateTime

    updatedBy: String
}

structure LiveSyncScriptMetadata {
    @length(max: 512)
    path: String

    tags: LiveSyncScriptTagList
}

@length(min: 1, max: 256)
string LiveSyncScriptTag

// ============================================================================
// Lists
// ============================================================================
list LiveSyncScriptSummaryList {
    member: LiveSyncScriptSummary
}

list LiveSyncScriptBuildList {
    member: LiveSyncScriptBuild
}

list LiveSyncScriptDeploymentList {
    member: LiveSyncScriptDeployment
}

@length(max: 5)
list LiveSyncScriptTagList {
    member: LiveSyncScriptTag
}

// ============================================================================
// Step Shapes — the live sync script body (mirrors the internal Journey.steps schema)
// ============================================================================
list LiveSyncScriptStepList {
    member: LiveSyncScriptStep
}

/// A single step in a live sync script.
structure LiveSyncScriptStep {
    @required
    stepId: UUIDv4

    @length(max: 100)
    name: String

    @length(max: 200)
    description: String

    action: LiveSyncScriptStepAction

    @length(max: 100)
    group: String

    @required
    @length(max: 1000)
    body: String

    skipTranslation: Boolean

    translated: Boolean

    variations: LiveSyncScriptStepVariationList

    trigger: LiveSyncScriptStepTrigger

    stateModifications: SimpleStateModificationList

    tags: AnalyticsTagReferenceList
}

enum LiveSyncScriptStepAction {
    ESCALATE = "escalate"
    END = "end"
    CONTINUE = "continue"
}

list LiveSyncScriptStepVariationList {
    member: LiveSyncScriptStepVariation
}

structure LiveSyncScriptStepVariation {
    @length(max: 1000)
    body: String

    @range(min: 0, max: 100)
    percentage: Double

    tags: AnalyticsTagReferenceList
}

structure LiveSyncScriptStepTrigger {
    event: LiveSyncScriptStepTriggerEvent
    query: Document
    once: Boolean
    highlight: Boolean
    urlCondition: LiveSyncScriptStepTriggerUrlCondition
}

enum LiveSyncScriptStepTriggerEvent {
    CLICK = "click"
    PAGE_LOAD = "pageLoad"
    APPEAR = "appear"
    ENTER_VIEWPORT = "enterViewport"
}

structure LiveSyncScriptStepTriggerUrlCondition {
    operator: LiveSyncScriptStepTriggerUrlOperator
    value: String
}

enum LiveSyncScriptStepTriggerUrlOperator {
    CONTAINS = "contains"
    MATCHES_REGEX = "matches_regex"
    SMART_MATCH = "smart_match"
}
