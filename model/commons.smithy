// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
$version: "2"

namespace com.amazon.connect.acxd.sdk

/// A UUID v4 string — server-generated, 36 characters, lowercase hex with dashes.
@pattern("^[0-9a-f]{8}-[0-9a-f]{4}-[0-5][0-9a-f]{3}-[089ab][0-9a-f]{3}-[0-9a-f]{12}$")
@length(min: 36, max: 36)
string UUIDv4

/// A string containing sensitive data (PII, user messages, etc.).
/// SDKs will not log or expose the value in toString() output.
@sensitive
string SensitiveString

/// Supported language codes.
enum LanguageCode {
    AR_AE = "ar-AE"
    AR_KW = "ar-KW"
    AR_MEA = "ar-MEA"
    AR_QA = "ar-QA"
    AR_SA = "ar-SA"
    AZ_AZ = "az-AZ"
    BG_BG = "bg-BG"
    BS_BA = "bs-BA"
    CA_ES = "ca-ES"
    CS_CZ = "cs-CZ"
    DA_DK = "da-DK"
    DE_AT = "de-AT"
    DE_CH = "de-CH"
    DE_DE = "de-DE"
    EL_GR = "el-GR"
    EN_INT = "en-INT"
    EN_CA = "en-CA"
    EN_IE = "en-IE"
    EN_IN = "en-IN"
    EN_NZ = "en-NZ"
    EN_PH = "en-PH"
    EN_PK = "en-PK"
    EN_SG = "en-SG"
    EN_ZA = "en-ZA"
    EN_EG = "en-EG"
    EN_KE = "en-KE"
    EN_KW = "en-KW"
    EN_MEA = "en-MEA"
    EN_MY = "en-MY"
    EN_NG = "en-NG"
    EN_UAE = "en-UAE"
    EN_AE = "en-AE"
    EN_AU = "en-AU"
    EN_GB = "en-GB"
    EN_QA = "en-QA"
    EN_SE = "en-SE"
    EN_US = "en-US"
    ES_419 = "es-419"
    ES_ES = "es-ES"
    ES_CB = "es-CB"
    ES_US = "es-US"
    ES_AR = "es-AR"
    ES_CL = "es-CL"
    ES_CO = "es-CO"
    ES_MX = "es-MX"
    ES_PE = "es-PE"
    ET_EE = "et-EE"
    FI_FI = "fi-FI"
    FR_BE = "fr-BE"
    FR_CA = "fr-CA"
    FR_CH = "fr-CH"
    FR_DZ = "fr-DZ"
    FR_FR = "fr-FR"
    HI_IN = "hi-IN"
    HR_HR = "hr-HR"
    HU_HU = "hu-HU"
    IS_IS = "is-IS"
    IT_IT = "it-IT"
    ID_ID = "id-ID"
    JA_JP = "ja-JP"
    KK_KZ = "kk-KZ"
    KO_KR = "ko-KR"
    LT_LT = "lt-LT"
    LV_LV = "lv-LV"
    MK_MK = "mk-MK"
    MS_MY = "ms-MY"
    NL_BE = "nl-BE"
    NL_NL = "nl-NL"
    NO_NO = "no-NO"
    PL_PL = "pl-PL"
    PT_BR = "pt-BR"
    PT_PT = "pt-PT"
    RO_RO = "ro-RO"
    RU_KZ = "ru-KZ"
    RU_RU = "ru-RU"
    SK_SK = "sk-SK"
    SL_SI = "sl-SI"
    SQ_AL = "sq-AL"
    SR_RS = "sr-RS"
    SV_SE = "sv-SE"
    TH_TH = "th-TH"
    TR_TR = "tr-TR"
    UK_UA = "uk-UA"
    VI_VN = "vi-VN"
    ZH_CN = "zh-CN"
    ZH_HK = "zh-HK"
    ZH_TW = "zh-TW"
}

list LanguageCodeList {
    member: LanguageCode
}

/// S3 bucket destination for scheduled downloads.
structure AwsS3Destination {
    @required
    bucket: String

    keyPrefix: String

    keyName: String

    region: String

    customerRoleArn: String
}

/// SFTP server destination for scheduled downloads.
structure SftpServerDestination {
    @required
    url: String

    connectorId: String

    username: String

    trustedHostKeys: TrustedHostKeyList

    remoteDirectoryPath: String

    pgpKey: String

    supportsRSAHostKey: Boolean
}

list TrustedHostKeyList {
    member: String
}

/// A simple state modification applied during guardrail enforcement or flow execution.
structure SimpleStateModification {
    type: StateModificationType
    name: String
    modification: StateModificationAction
    functionName: String
    value: Operand
}

/// An operand representing a value source for state modifications.
structure Operand {
    @required
    type: OperandType

    name: String

    value: Document

    modification: OperandModification
}

enum OperandType {
    CAPTURED_INTENT = "captured_intent"
    FIELD = "field"
    RANDOM_NUMBER = "random_number"
    COMPUTED = "computed"
    LOCAL = "local"
    CONSTANT = "constant"
    JSON = "json"
    CONSTANT_ID = "constant_id"
    CONTEXT = "context"
    KNOWLEDGE_BASE_METADATA = "knowledge_base_metadata"
    NODE_STATUS = "node_status"
    RECURSIVE = "recursive"
    SLOT = "slot"
    SLOT_VALUE_ID = "slot_value_id"
    SYSTEM = "system"
    VARIABLE = "variable"
    VARIABLE_SELECTION = "variable_selection"
}

enum OperandModification {
    INCREMENT = "increment"
    DECREMENT = "decrement"
    CAPITALIZE = "capitalize"
    LENGTH = "length"
    LOWER = "lower"
    REMOVE_WHITESPACE = "remove-whitespace"
    LOWER_REMOVE_WHITESPACE = "lower-remove-whitespace"
    UPPER = "upper"
    UPPER_REMOVE_WHITESPACE = "upper-remove-whitespace"
    PARSE_DATE = "parse-date"
    FIRST = "first"
    BASE64_ENCODE = "base64-encode"
}

enum StateModificationType {
    CONTEXT = "context"
}

enum StateModificationAction {
    CLEAR = "clear"
    SET = "set"
    INCREMENT = "increment"
    DECREMENT = "decrement"
    PUSH = "push"
    POP = "pop"
    CUSTOM = "custom"
}

list SimpleStateModificationList {
    member: SimpleStateModification
}

/// Sort fields for conversation list queries.
enum ConversationSortBy {
    CHANNEL_TYPE = "channelType"
    FIRST_TIMESTAMP = "firstTimestamp"
    FIRST_UTTERANCE = "firstUtterance"
    ELAPSED_SECONDS = "elapsedSeconds"
    FLOW_IDS = "flowIds"
}

/// Sort order for list queries.
enum SortOrder {
    ASC = "asc"
    DESC = "desc"
}

/// Duration window in hours.
integer DurationInHours

/// Conversation identifier — alphanumeric with dashes, underscores, dots, and colons.
@pattern("^[A-Za-z0-9-_.:]+$")
@length(min: 5, max: 255)
string ConversationId

/// Base message shape — shared fields for all message types.
@mixin
structure _BaseMessage {
    messageId: String
    type: MessageType
    body: String
    skipTranslation: Boolean
    translated: Boolean
    metadata: MessageMetadata
}

/// A message with required type and body.
structure Message with [_BaseMessage] {
    @required
    type: MessageType

    @required
    body: String
}

enum MessageType {
    TEXT = "text"
    SSML = "ssml"
}

structure MessageMetadata {
    alternatePhrasings: AlternatePhraseList
}

list AlternatePhraseList {
    member: String
}

list MessageList {
    member: Message
}

/// An interim message displayed during async processing.
structure InterimMessage {
    messageId: String
    text: String
    delay: Integer
}

list InterimMessageList {
    member: InterimMessage
}

/// Base structure for a knowledge base article question.
@mixin
structure _BaseKnowledgeBaseArticleQuestion {
    text: String
    messageId: UUIDv4
    skipTranslation: Boolean
    translated: Boolean
}

/// A knowledge base article question with required text.
structure KnowledgeBaseArticleQuestion with [_BaseKnowledgeBaseArticleQuestion] {
    @required
    @length(max: 240)
    text: String
}

// ============================================================================
// Enums — Roles (shared across users, roles, programmaticUsers)
// ============================================================================
/// Predefined role names with built-in permission sets.
enum PredefinedRoleName {
    ADMINISTRATOR = "administrator"
    ANALYST = "analyst"
    CONTENT_MANAGER = "content_manager"
    DEVELOPER = "developer"
    READ_ONLY = "read-only"
}

@timestampFormat("date-time")
timestamp DateTime
