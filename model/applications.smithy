// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
$version: "2"

namespace com.amazon.connect.acxd.sdk

// ============================================================================
// Operations — Applications (Core CRUD)
// ============================================================================
@http(method: "GET", uri: "/sdk/applications")
@readonly
@paginated(inputToken: "nextToken", outputToken: "nextToken", items: "items", pageSize: "maxResults")
operation ListApplications {
    input: ListApplicationsRequest
    output: ListApplicationsResponse
    errors: [
        ValidationException
        InternalServerException
    ]
}

@http(method: "POST", uri: "/sdk/applications", code: 201)
operation CreateApplication {
    input: CreateApplicationRequest
    output: Application
    errors: [
        ValidationException
        ConflictException
        InternalServerException
    ]
}

@http(method: "GET", uri: "/sdk/applications/{applicationIdentifier}")
@readonly
operation GetApplication {
    input: GetApplicationRequest
    output: Application
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

@http(method: "PATCH", uri: "/sdk/applications/{applicationIdentifier}")
@idempotent
operation UpdateApplication {
    input: UpdateApplicationRequest
    output: Application
    errors: [
        ResourceNotFoundException
        ValidationException
        InternalServerException
    ]
}

@http(method: "DELETE", uri: "/sdk/applications/{applicationIdentifier}", code: 204)
@idempotent
operation DeleteApplication {
    input: DeleteApplicationRequest
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

// ============================================================================
// Operations — Application Builds
// ============================================================================
@http(method: "GET", uri: "/sdk/applications/{applicationIdentifier}/builds")
@readonly
@paginated(inputToken: "nextToken", outputToken: "nextToken", items: "items", pageSize: "maxResults")
operation ListApplicationBuilds {
    input: ListApplicationBuildsRequest
    output: ListApplicationBuildsResponse
    errors: [
        ResourceNotFoundException
        ValidationException
        InternalServerException
    ]
}

@http(method: "POST", uri: "/sdk/applications/{applicationIdentifier}/builds", code: 201)
operation CreateApplicationBuild {
    input: CreateApplicationBuildRequest
    output: ApplicationBuild
    errors: [
        ResourceNotFoundException
        ValidationException
        InternalServerException
    ]
}

@http(method: "GET", uri: "/sdk/applications/{applicationIdentifier}/builds/{buildIdentifier}")
@readonly
operation GetApplicationBuild {
    input: GetApplicationBuildRequest
    output: ApplicationBuild
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

@http(method: "GET", uri: "/sdk/applications/{applicationIdentifier}/builds/{buildIdentifier}/diff")
@readonly
operation GetApplicationBuildDiff {
    input: GetApplicationBuildDiffRequest
    output: GetApplicationBuildDiffResponse
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

// ============================================================================
// Operations — Application Deployments
// ============================================================================
@http(method: "GET", uri: "/sdk/applications/{applicationIdentifier}/deployments")
@readonly
@paginated(inputToken: "nextToken", outputToken: "nextToken", items: "items", pageSize: "maxResults")
operation ListApplicationDeployments {
    input: ListApplicationDeploymentsRequest
    output: ListApplicationDeploymentsResponse
    errors: [
        ResourceNotFoundException
        ValidationException
        InternalServerException
    ]
}

@http(method: "POST", uri: "/sdk/applications/{applicationIdentifier}/deployments", code: 201)
operation CreateApplicationDeployment {
    input: CreateApplicationDeploymentRequest
    output: ApplicationDeployment
    errors: [
        ResourceNotFoundException
        ValidationException
        InternalServerException
    ]
}

@http(method: "GET", uri: "/sdk/applications/{applicationIdentifier}/deployments/{deploymentIdentifier}")
@readonly
operation GetApplicationDeployment {
    input: GetApplicationDeploymentRequest
    output: ApplicationDeployment
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

@http(method: "PATCH", uri: "/sdk/applications/{applicationIdentifier}/deployments/{deploymentIdentifier}")
@idempotent
operation UpdateApplicationDeployment {
    input: UpdateApplicationDeploymentRequest
    output: ApplicationDeployment
    errors: [
        ResourceNotFoundException
        ValidationException
        InternalServerException
    ]
}

@http(method: "DELETE", uri: "/sdk/applications/{applicationIdentifier}/deployments/{deploymentIdentifier}", code: 204)
@idempotent
operation DeleteApplicationDeployment {
    input: DeleteApplicationDeploymentRequest
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

// ============================================================================
// Custom Types — Applications
// ============================================================================
@pattern("^[A-Za-z0-9 _-]+$")
@length(min: 1, max: 100)
string ApplicationName

@pattern("^[ -~]*$")
@length(max: 200)
string ApplicationDescription

@length(max: 16)
string BuildVersion

enum DeploymentEnvironment {
    DEVELOPMENT = "development"
    QA = "qa"
    STAGING = "staging"
    PRODUCTION = "production"
}

// ============================================================================
// Request/Response Structures — Applications
// ============================================================================
structure ListApplicationsRequest {
    @httpQuery("nextToken")
    nextToken: String

    @httpQuery("maxResults")
    @range(min: 1, max: 500)
    maxResults: Integer
}

structure ListApplicationsResponse {
    @required
    items: ApplicationSummaryList

    nextToken: String
}

structure CreateApplicationRequest {
    @required
    name: ApplicationName

    flows: FlowReferenceList

    @required
    settings: ApplicationSettings

    description: ApplicationDescription

    metadata: ApplicationMetadata

    deploymentSettings: ApplicationDeploymentSettings
}

structure GetApplicationRequest {
    @required
    @httpLabel
    applicationIdentifier: UUIDv4
}

structure UpdateApplicationRequest {
    @required
    @httpLabel
    applicationIdentifier: UUIDv4

    name: ApplicationName

    flows: FlowReferenceList

    settings: ApplicationSettings

    description: ApplicationDescription

    metadata: ApplicationMetadata

    deploymentSettings: ApplicationDeploymentSettings
}

structure DeleteApplicationRequest {
    @required
    @httpLabel
    applicationIdentifier: UUIDv4
}

// ============================================================================
// Request/Response Structures — Builds
// ============================================================================
structure CreateApplicationBuildRequest {
    @required
    @httpLabel
    applicationIdentifier: UUIDv4

    @default("")
    version: BuildVersion

    description: ApplicationDescription

    languageSettings: LanguageSettingList
}

structure ListApplicationBuildsRequest {
    @required
    @httpLabel
    applicationIdentifier: UUIDv4

    @httpQuery("nextToken")
    nextToken: String

    @httpQuery("maxResults")
    @range(min: 1, max: 500)
    maxResults: Integer
}

structure ListApplicationBuildsResponse {
    @required
    items: ApplicationBuildList

    nextToken: String
}

structure GetApplicationBuildRequest {
    @required
    @httpLabel
    applicationIdentifier: UUIDv4

    @required
    @httpLabel
    buildIdentifier: UUIDv4
}

structure GetApplicationBuildDiffRequest {
    @required
    @httpLabel
    applicationIdentifier: UUIDv4

    @required
    @httpLabel
    buildIdentifier: UUIDv4

    @required
    @httpQuery("previousBuildIdentifier")
    previousBuildIdentifier: UUIDv4
}

structure GetApplicationBuildDiffResponse {
    @required
    application: ApplicationBuildDiffResult
}

/// Diff result showing what changed between two application builds.
structure ApplicationBuildDiffResult {
    properties: Document
    settings: Document
    modifiedSlotTypes: Document
    modifiedDataRequests: Document
    modifiedActions: Document
    attachedFlows: Document
    detachedFlows: Document
    modifiedFlows: Document
}

// ============================================================================
// Request/Response Structures — Deployments
// ============================================================================
structure ListApplicationDeploymentsRequest {
    @required
    @httpLabel
    applicationIdentifier: UUIDv4

    @httpQuery("nextToken")
    nextToken: String

    @httpQuery("maxResults")
    @range(min: 1, max: 500)
    maxResults: Integer
}

structure ListApplicationDeploymentsResponse {
    @required
    items: ApplicationDeploymentList

    nextToken: String
}

structure CreateApplicationDeploymentRequest {
    @required
    @httpLabel
    applicationIdentifier: UUIDv4

    @required
    buildIdentifier: UUIDv4

    description: ApplicationDescription

    environment: DeploymentEnvironment

    languageCodes: LanguageCodeList

    analyticsTags: AnalyticsTagReferenceList

    contextVariables: ContextVariableValueList
}

structure GetApplicationDeploymentRequest {
    @required
    @httpLabel
    applicationIdentifier: UUIDv4

    @required
    @httpLabel
    deploymentIdentifier: UUIDv4
}

structure UpdateApplicationDeploymentRequest {
    @required
    @httpLabel
    applicationIdentifier: UUIDv4

    @required
    @httpLabel
    deploymentIdentifier: UUIDv4

    @required
    buildIdentifier: UUIDv4

    description: ApplicationDescription

    environment: DeploymentEnvironment

    languageCodes: LanguageCodeList

    analyticsTags: AnalyticsTagReferenceList

    contextVariables: ContextVariableValueList
}

structure DeleteApplicationDeploymentRequest {
    @required
    @httpLabel
    applicationIdentifier: UUIDv4

    @required
    @httpLabel
    deploymentIdentifier: UUIDv4
}

// ============================================================================
// Resource Shapes
// ============================================================================
/// Full application resource — returned by Create, Get, Update.
structure Application {
    @required
    applicationId: UUIDv4

    @required
    name: ApplicationName

    @required
    flows: FlowReferenceList

    @required
    settings: ApplicationSettings

    description: ApplicationDescription

    metadata: ApplicationMetadata

    deploymentSettings: ApplicationDeploymentSettings

    @required
    createdAt: DateTime

    @required
    updatedAt: DateTime

    updatedBy: String
}

/// Summary shape for list responses (excludes settings and other large fields).
structure ApplicationSummary {
    @required
    applicationId: UUIDv4

    @required
    name: ApplicationName

    description: ApplicationDescription

    metadata: ApplicationMetadata

    @required
    createdAt: DateTime

    @required
    updatedAt: DateTime
}

structure ApplicationBuild {
    @required
    buildId: UUIDv4

    @required
    applicationId: UUIDv4

    @required
    @length(max: 64)
    status: String

    @default("")
    version: BuildVersion

    description: ApplicationDescription

    languageSettings: LanguageSettingList

    @required
    createdAt: DateTime

    @required
    updatedAt: DateTime

    updatedBy: String
}

structure ApplicationDeployment {
    @required
    deploymentId: UUIDv4

    @required
    applicationId: UUIDv4

    @required
    buildId: UUIDv4

    description: ApplicationDescription

    deploymentStatus: String

    environment: DeploymentEnvironment

    languageCodes: LanguageCodeList

    analyticsTags: AnalyticsTagReferenceList

    contextVariables: ContextVariableValueList

    @required
    createdAt: DateTime

    @required
    updatedAt: DateTime

    updatedBy: String
}

structure ApplicationMetadata {
    @length(max: 512)
    path: String

    tags: ApplicationTagList
}

/// Application settings controlling language, guardrails, and runtime behavior.
structure ApplicationSettings {
    languageCode: LanguageCode

    languageCodes: LanguageCodeList

    languageSettings: LanguageSettingList

    guardrails: GuardrailReferenceList

    lifecycleHooks: LifecycleHooks

    defaultFlows: DefaultFlows

    thresholds: ApplicationThresholds

    @default(5)
    @range(min: 1, max: 60)
    conversationTTL: Integer

    @default(false)
    autoCorrection: Boolean

    @default(false)
    childDirected: Boolean

    @default(false)
    repeatOnIncomprehension: Boolean

    clusters: ClusterSettings
}

structure LanguageSetting {
    @required
    languageCode: LanguageCode

    useNativeLanguage: Boolean

    useLex3pAsr: Boolean

    @default("")
    projectId: String

    region: LanguageRegion

    voice: String
}

enum LanguageRegion {
    GLOBAL = "global"
    EU = "eu"
}

structure LifecycleHooks {
    conversationStart: UUIDv4
    conversationEnd: UUIDv4
    escalation: UUIDv4
    stateModification: UUIDv4
    messageReceived: UUIDv4
}

structure DefaultFlows {
    @jsonName("ACXD.Welcome")
    welcome: DefaultFlowConfig

    @jsonName("ACXD.Fallback")
    fallback: DefaultFlowConfig

    @jsonName("ACXD.Unknown")
    unknown: DefaultFlowConfigWithKnowledgeBase

    @jsonName("ACXD.Escalation")
    escalation: DefaultFlowConfig

    @jsonName("ACXD.Frustration")
    frustration: DefaultFlowConfig

    @jsonName("ACXD.Help")
    help: DefaultFlowConfig

    @jsonName("ACXD.Repeat")
    repeat: DefaultFlowConfig

    @jsonName("ACXD.Resume")
    resume: DefaultFlowConfig
}

structure DefaultFlowConfig {
    flowId: String
    quickReplies: QuickReplyList
}

structure DefaultFlowConfigWithKnowledgeBase {
    flowId: String
    knowledgeBaseId: String
    quickReplies: QuickReplyList
}

structure ApplicationThresholds {
    @default(2)
    incomprehensionCount: Integer
}

structure ClusterSettings {
    @default(false)
    enabled: Boolean

    frequency: ClusterFrequency

    phraseThreshold: ClusterPhraseThreshold

    retention: ClusterRetention
}

structure ClusterFrequency {
    @default(1)
    count: Integer

    resolution: ClusterResolution
}

structure ClusterPhraseThreshold {
    @default(100)
    @range(min: 30)
    count: Integer
}

structure ClusterRetention {
    @default(30)
    @range(min: 1, max: 90)
    count: Integer

    resolution: RetentionResolution
}

enum ClusterResolution {
    HOUR = "HOUR"
    DAY = "DAY"
    WEEK = "WEEK"
    MONTH = "MONTH"
}

enum RetentionResolution {
    DAY = "DAY"
}

structure GuardrailReference {
    @required
    guardrailId: String
}

/// Deployment settings for one-click deploy.
structure ApplicationDeploymentSettings {
    oneClickDeployEnabled: Boolean
    environment: DeploymentEnvironment
    contextVariables: ContextVariableValueList
}

structure ContextVariableValue {
    @required
    @length(min: 1, max: 64)
    @pattern("^[A-Za-z_]+$")
    key: String

    @required
    value: Document
}

structure FlowReference {
    @required
    flowId: String
}

structure AnalyticsTagReference {
    @required
    label: String
}

// ============================================================================
// Lists
// ============================================================================
list ApplicationSummaryList {
    member: ApplicationSummary
}

list ApplicationDeploymentList {
    member: ApplicationDeployment
}

list ApplicationBuildList {
    member: ApplicationBuild
}

list FlowReferenceList {
    member: FlowReference
}

list AnalyticsTagReferenceList {
    member: AnalyticsTagReference
}

list GuardrailReferenceList {
    member: GuardrailReference
}

list LanguageSettingList {
    member: LanguageSetting
}

list QuickReplyList {
    member: String
}

@length(max: 50)
list ContextVariableValueList {
    member: ContextVariableValue
}

@length(max: 5)
list ApplicationTagList {
    member: ApplicationTag
}

@length(min: 1, max: 256)
string ApplicationTag

list StringList {
    member: String
}
