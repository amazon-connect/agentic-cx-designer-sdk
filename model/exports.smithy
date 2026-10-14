// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
$version: "2"

namespace com.amazon.connect.acxd.sdk

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
        ConflictException
        InternalServerException
    ]
}

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

/// An opaque value identifying one export request, so a retry does not start a
/// second export. Printable ASCII.
@pattern("^[!-~]+$")
@length(min: 1, max: 128)
string IdempotencyToken

structure ExportResourceRequest {
    @required
    resourceType: ExportableResourceType

    @required
    resourceIdentifier: String

    /// Retrying with the same token answers the export the first call started,
    /// rather than starting a second one. Honoured for as long as that
    /// download's record lives. Generated for you if omitted.
    @idempotencyToken
    clientToken: IdempotencyToken
}

structure ExportResourceResponse {
    @required
    downloadIdentifier: UUIDv4
}
