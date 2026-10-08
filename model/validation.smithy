// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
$version: "2"

namespace com.amazon.connect.acxd.sdk

// ============================================================================
// Operations — Validation
// ============================================================================
/// Validates a resource, optionally together with everything it depends on.
@http(method: "POST", uri: "/sdk/validation")
operation ValidateResource {
    input: ValidateResourceRequest
    output: ValidateResourceResponse
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

// ============================================================================
// Custom Types — Validation
// ============================================================================
/// How far to follow a resource's references.
enum ValidationMode {
    /// Validate the named resource alone.
    SINGLE = "single"

    /// Validate everything reachable from the named resource.
    GRAPH = "graph"
}

/// The resource kinds validation supports.
enum ValidatableResourceType {
    APPLICATIONS = "applications"
    FLOWS = "flows"
    SLOT_TYPES = "slotTypes"
    DATA_REQUESTS = "dataRequests"
    CONTEXT_VARIABLES = "contextVariables"
    ANALYTICS_TAGS = "analyticsTags"
    LIVE_SYNC_SCRIPTS = "liveSyncScripts"
    KNOWLEDGE_BASES = "knowledgeBases"
    MODALITIES = "modalities"
    SECRETS = "secrets"
    GUARDRAILS = "guardrails"
}

/// A resource that was validated.
structure ValidatedResource {
    @required
    type: ValidatableResourceType

    @required
    id: String

    name: String
}

/// A problem found during validation. `code` identifies the check; the
/// accompanying detail fields name the resources involved and vary by code.
structure ValidationIssue {
    @required
    code: String
}

list ValidationIssueList {
    member: ValidationIssue
}

/// A node in the dependency graph: a resource and what validating it found.
structure ValidationResource {
    @required
    id: Integer

    @required
    resource: ValidatedResource

    @required
    errors: ValidationIssueList

    @required
    warnings: ValidationIssueList
}

list ValidationResourceList {
    member: ValidationResource
}

/// An edge between two `ValidationResource` ids.
structure ValidationResourceLink {
    @required
    from: Integer

    @required
    to: Integer
}

list ValidationResourceLinkList {
    member: ValidationResourceLink
}

// ============================================================================
// Request Structures
// ============================================================================
structure ValidateResourceRequest {
    @required
    mode: ValidationMode

    @required
    resourceType: ValidatableResourceType

    @required
    resourceId: String
}

// ============================================================================
// Response Structures
// ============================================================================
structure ValidateResourceResponse {
    @required
    resources: ValidationResourceList

    @required
    resourceLinks: ValidationResourceLinkList
}
