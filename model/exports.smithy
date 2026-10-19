// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
$version: "2"

namespace com.amazon.connect.acxd.sdk

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

@http(method: "GET", uri: "/sdk/exports/{downloadId}")
@readonly
operation GetResourceExport {
    input: GetResourceExportRequest
    output: GetResourceExportResponse
    errors: [
        ValidationException
        ResourceNotFoundException
        ConflictException
        InternalServerException
    ]
}

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

@pattern("^[!-~]+$")
@length(min: 1, max: 128)
string IdempotencyToken

structure ExportResourceRequest {
    @required
    resourceType: ExportableResourceType

    @required
    resourceIdentifier: String

    @idempotencyToken
    clientToken: IdempotencyToken
}

structure ExportResourceResponse {
    @required
    downloadId: UUIDv4
}

structure GetResourceExportRequest {
    @required
    @httpLabel
    downloadId: UUIDv4
}

structure GetResourceExportResponse {
    @required
    url: String
}
