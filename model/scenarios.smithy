// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
$version: "2"

namespace com.amazon.connect.acxd.sdk

// ============================================================================
// Operations — Scenarios
// ============================================================================
/// Lists all scenarios for the workspace.
@http(method: "GET", uri: "/sdk/scenarios")
@readonly
operation ListScenarios {
    input: ListScenariosRequest
    output: ListScenariosResponse
    errors: [
        ValidationException
        InternalServerException
    ]
}

/// Creates a new scenario.
@http(method: "POST", uri: "/sdk/scenarios", code: 201)
operation CreateScenario {
    input: CreateScenarioRequest
    output: Scenario
    errors: [
        ValidationException
        ConflictException
        InternalServerException
    ]
}

/// Retrieves a single scenario by ID.
@http(method: "GET", uri: "/sdk/scenarios/{scenarioId}")
@readonly
operation GetScenario {
    input: GetScenarioRequest
    output: Scenario
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

/// Updates an existing scenario.
@http(method: "PATCH", uri: "/sdk/scenarios/{scenarioId}")
@idempotent
operation UpdateScenario {
    input: UpdateScenarioRequest
    output: Scenario
    errors: [
        ResourceNotFoundException
        ValidationException
        InternalServerException
    ]
}

/// Deletes a scenario by ID.
@http(method: "DELETE", uri: "/sdk/scenarios/{scenarioId}", code: 204)
@idempotent
operation DeleteScenario {
    input: DeleteScenarioRequest
    errors: [
        ResourceNotFoundException
        ValidationException
        InternalServerException
    ]
}

// ============================================================================
// Custom Types — Scenarios
// ============================================================================
/// Scenario name.
@pattern("^[A-Za-z0-9 _-]+$")
@length(min: 1, max: 255)
string ScenarioName

/// Scenario description — printable ASCII text.
@pattern("^[ -~]*$")
@length(max: 100)
string ScenarioDescription

/// Scenario outcome — printable ASCII text.
@pattern("^[ -~]*$")
@length(min: 1, max: 255)
string ScenarioOutcome

/// Scenario persona — printable ASCII text.
@pattern("^[ -~]*$")
@length(max: 1000)
string ScenarioPersona

/// Type of scenario metadata entry.
enum ScenarioMetadataEntryType {
    CONTEXT = "context"
    SYSTEM = "system"
}

// ============================================================================
// Request Structures
// ============================================================================
structure ListScenariosRequest {
    @httpQuery("nextToken")
    nextToken: String

    @httpQuery("maxResults")
    @range(min: 1, max: 100)
    maxResults: Integer
}

structure CreateScenarioRequest {
    @required
    name: ScenarioName

    @required
    outcome: ScenarioOutcome

    description: ScenarioDescription

    persona: ScenarioPersona

    @range(min: 1, max: 50)
    maxTurns: Integer

    terminationConditions: TerminationConditionList

    metadata: ScenarioMetadata
}

structure GetScenarioRequest {
    @required
    @httpLabel
    scenarioId: UUIDv4
}

structure UpdateScenarioRequest {
    @required
    @httpLabel
    scenarioId: UUIDv4

    name: ScenarioName

    outcome: ScenarioOutcome

    description: ScenarioDescription

    persona: ScenarioPersona

    @range(min: 1, max: 50)
    maxTurns: Integer

    terminationConditions: TerminationConditionList

    metadata: ScenarioMetadata
}

structure DeleteScenarioRequest {
    @required
    @httpLabel
    scenarioId: UUIDv4
}

// ============================================================================
// Response Structures
// ============================================================================
structure ListScenariosResponse {
    @required
    items: ScenarioList

    nextToken: String
}

// ============================================================================
// Resource Shapes
// ============================================================================
/// Full scenario resource.
structure Scenario {
    @required
    scenarioId: UUIDv4

    name: ScenarioName

    outcome: ScenarioOutcome

    description: ScenarioDescription

    persona: ScenarioPersona

    @range(min: 1, max: 50)
    maxTurns: Integer

    terminationConditions: TerminationConditionList

    metadata: ScenarioMetadata

    @required
    createdAt: DateTime

    @required
    updatedAt: DateTime

    updatedBy: String
}

/// A termination condition for a scenario.
structure TerminationCondition {
    conditionId: String

    name: String

    @required
    prompt: String
}

/// A metadata entry for a scenario (context or system variable).
structure ScenarioMetadataEntry {
    type: ScenarioMetadataEntryType
    name: String
    value: Document
}

/// Resource metadata — path, classification tags, and scenario context entries.
structure ScenarioMetadata {
    @length(max: 512)
    path: String

    tags: ScenarioTagList

    entries: ScenarioMetadataEntryList
}

// ============================================================================
// Lists
// ============================================================================
list ScenarioList {
    member: Scenario
}

@length(max: 10)
list TerminationConditionList {
    member: TerminationCondition
}

list ScenarioMetadataEntryList {
    member: ScenarioMetadataEntry
}

@length(max: 5)
list ScenarioTagList {
    member: ScenarioTag
}

@length(min: 1, max: 256)
string ScenarioTag
