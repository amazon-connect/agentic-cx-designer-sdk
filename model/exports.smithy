// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
$version: "2"

namespace com.amazon.connect.acxd.sdk

// ============================================================================
// Operations — Exports
// ============================================================================
/// Exports a resource together with everything it depends on, as a bundle
/// Agentic CX Designer Studio can import. Asynchronous: poll GetDownload with
/// the returned `downloadIdentifier` for a presigned URL.
@http(method: "POST", uri: "/sdk/exports", code: 202)
operation ExportResource {
    input: ExportResourceRequest
    output: ExportResourceResponse
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

// ============================================================================
// Custom Types — Exports
// ============================================================================
/// The resource kinds that can be an export root. Secrets are absent: a
/// secret's value is never returned by the API.
enum ExportableResourceType {
    APPLICATIONS = "applications"
    FLOWS = "flows"
    SLOT_TYPES = "slotTypes"
    DATA_REQUESTS = "dataRequests"
    CONTEXT_VARIABLES = "contextVariables"
    ANALYTICS_TAGS = "analyticsTags"
    LIVE_SYNC_SCRIPTS = "liveSyncScripts"
    KNOWLEDGE_BASES = "knowledgeBases"
    MODALITIES = "modalities"
    GUARDRAILS = "guardrails"
}

// ============================================================================
// Request/Response Structures — ExportResource
// ============================================================================
structure ExportResourceRequest {
    @required
    resourceType: ExportableResourceType

    @required
    resourceId: String
}

structure ExportResourceResponse {
    @required
    downloadIdentifier: String

    @required
    status: String
}
