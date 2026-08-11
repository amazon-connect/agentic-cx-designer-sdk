// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
$version: "2"

namespace com.amazon.connect.acxd.sdk

// ============================================================================
// Operations — Analytics Tags
// ============================================================================
/// Creates a new analytics tag and returns the created tag.
@http(method: "POST", uri: "/sdk/analytics-tags", code: 201)
operation CreateAnalyticsTag {
    input: CreateAnalyticsTagRequest
    output: AnalyticsTagEntry
    errors: [
        ValidationException
        ConflictException
        InternalServerException
    ]
}

/// Lists all analytics tags for the workspace.
@http(method: "GET", uri: "/sdk/analytics-tags")
@readonly
operation ListAnalyticsTags {
    input: ListAnalyticsTagsRequest
    output: AnalyticsTagsResponse
    errors: [
        ValidationException
        InternalServerException
    ]
}

/// Updates an existing analytics tag by name and returns the updated tag.
@http(method: "PATCH", uri: "/sdk/analytics-tags/{name}")
@idempotent
operation UpdateAnalyticsTag {
    input: UpdateAnalyticsTagRequest
    output: AnalyticsTagEntry
    errors: [
        ResourceNotFoundException
        ValidationException
        InternalServerException
    ]
}

/// Deletes an analytics tag by name.
@http(method: "DELETE", uri: "/sdk/analytics-tags/{name}", code: 204)
@idempotent
operation DeleteAnalyticsTag {
    input: DeleteAnalyticsTagRequest
    errors: [
        ResourceNotFoundException
        ValidationException
        InternalServerException
    ]
}

// ============================================================================
// Custom Types — Analytics Tags
// ============================================================================
/// Analytics tag name — alphanumeric label identifying the tag.
@pattern("^[A-Z_a-z0-9]+$")
@length(min: 1, max: 36)
string AnalyticsTagName

/// Analytics tag description — printable ASCII text.
@pattern("^[ -~]*$")
@length(max: 64)
string AnalyticsTagDescription

/// The sentiment classification type of an analytics tag.
enum AnalyticsTagType {
    POSITIVE = "positive"
    NEGATIVE = "negative"
    NEUTRAL = "neutral"
}

// ============================================================================
// Request/Response Structures
// ============================================================================
structure CreateAnalyticsTagRequest {
    @required
    name: AnalyticsTagName

    @required
    type: AnalyticsTagType

    @required
    description: AnalyticsTagDescription

    metadata: AnalyticsTagMetadata
}

structure ListAnalyticsTagsRequest {}

structure UpdateAnalyticsTagRequest {
    @required
    @httpLabel
    name: AnalyticsTagName

    type: AnalyticsTagType

    description: AnalyticsTagDescription

    metadata: AnalyticsTagMetadata
}

structure DeleteAnalyticsTagRequest {
    @required
    @httpLabel
    name: AnalyticsTagName
}

// ============================================================================
// Response Structures
// ============================================================================
/// Response containing the full set of analytics tags for the workspace.
structure AnalyticsTagsResponse {
    @required
    items: AnalyticsTagEntryList
}

// ============================================================================
// Resource Shapes
// ============================================================================
/// A single analytics tag entry in the analytics tags collection.
structure AnalyticsTagEntry {
    @required
    name: AnalyticsTagName

    @required
    type: AnalyticsTagType

    @required
    description: AnalyticsTagDescription

    isSystemTag: Boolean

    metadata: AnalyticsTagMetadata

    createdAt: DateTime

    updatedAt: DateTime

    lastUpdatedBy: String
}

/// Metadata for an analytics tag — path and classification tags.
structure AnalyticsTagMetadata {
    @length(max: 512)
    path: String

    tags: AnalyticsTagMetadataTagList
}

// ============================================================================
// Lists
// ============================================================================
list AnalyticsTagEntryList {
    member: AnalyticsTagEntry
}

@length(max: 5)
list AnalyticsTagMetadataTagList {
    member: AnalyticsTagMetadataTag
}

@length(min: 1, max: 256)
string AnalyticsTagMetadataTag
