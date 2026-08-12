// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
$version: "2"

namespace com.amazon.connect.acxd.sdk

// ============================================================================
// Operations — Versions
// ============================================================================
/// Lists version history for a resource.
@http(method: "GET", uri: "/sdk/versions")
@readonly
operation ListResourceVersions {
    input: ListResourceVersionsRequest
    output: ListResourceVersionsResponse
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

/// Retrieves a specific version of a resource.
@http(method: "GET", uri: "/sdk/versions/{versionId}")
@readonly
operation GetResourceVersion {
    input: GetResourceVersionRequest
    output: GetResourceVersionResponse
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

// ============================================================================
// Custom Types — Versions
// ============================================================================
/// The type of versioned resource.
enum VersionedResourceType {
    SLOT_TYPES = "slotTypes"
    FLOWS = "flows"
    DATA_REQUESTS = "dataRequests"
    ACTIONS = "actions"
    LIFECYCLE_HOOKS = "lifecycleHooks"
    JOURNEYS = "journeys"
    GUARDRAILS = "guardrails"
    FEEDBACK_CONFIGS = "feedbackConfigs"
}

// ============================================================================
// Request Structures
// ============================================================================
structure ListResourceVersionsRequest {
    @required
    @httpQuery("resourceType")
    resourceType: VersionedResourceType

    @required
    @httpQuery("resourceId")
    resourceId: String

    @httpQuery("nextToken")
    nextToken: String

    @httpQuery("maxResults")
    @range(min: 1, max: 100)
    maxResults: Integer
}

structure GetResourceVersionRequest {
    @required
    @httpLabel
    versionId: String

    @required
    @httpQuery("resourceType")
    resourceType: VersionedResourceType

    @required
    @httpQuery("resourceId")
    resourceId: String
}

// ============================================================================
// Response Structures
// ============================================================================
structure ListResourceVersionsResponse {
    @required
    items: ResourceVersionSummaryList

    nextToken: String
}

structure GetResourceVersionResponse {
    @required
    data: ResourceVersionData
}

/// Version data — exactly one variant will be present based on resourceType.
union ResourceVersionData {
    slotType: Document
    flow: Document
    dataRequest: Document
    action: Document
    lifecycleHook: Document
    journey: Document
    guardrail: Document
    feedbackConfig: Document
}

// ============================================================================
// Resource Shapes
// ============================================================================
structure ResourceVersionSummary {
    @required
    versionId: String

    lastUpdatedBy: String

    updatedAt: DateTime

    isLatest: Boolean

    isPublished: Boolean
}

// ============================================================================
// Lists
// ============================================================================
list ResourceVersionSummaryList {
    member: ResourceVersionSummary
}
