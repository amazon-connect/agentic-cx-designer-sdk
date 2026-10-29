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
        ConflictException
        InternalServerException
    ]
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
// Shared Types (referenced by conversations.smithy, guardrails.smithy)
// ============================================================================
enum BooleanString {
    TRUE = "true"
    FALSE = "false"
}

enum DownloadStatus {
    IN_PROGRESS = "IN_PROGRESS"
    SUCCEEDED = "SUCCEEDED"
    FAILED = "FAILED"
}
