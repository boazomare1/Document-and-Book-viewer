import 'package:json_annotation/json_annotation.dart';

part 'digital_signatures.g.dart';

enum SignatureType {
  digital,
  electronic,
  timestamp,
  approval,
  certification,
}

enum SignatureStatus {
  valid,
  invalid,
  unknown,
  expired,
  revoked,
  notTrusted,
}

enum CertificateType {
  selfSigned,
  caSigned,
  codeSigning,
  email,
  documentSigning,
}

@JsonSerializable()
class DigitalCertificate {
  final String id;
  final String subjectName;
  final String issuerName;
  final String serialNumber;
  final DateTime validFrom;
  final DateTime validTo;
  final CertificateType type;
  final String? email;
  final String? organization;
  final String? country;
  final String? publicKey;
  final Map<String, dynamic> extensions;
  final bool isTrusted;
  final bool isRevoked;

  const DigitalCertificate({
    required this.id,
    required this.subjectName,
    required this.issuerName,
    required this.serialNumber,
    required this.validFrom,
    required this.validTo,
    required this.type,
    this.email,
    this.organization,
    this.country,
    this.publicKey,
    required this.extensions,
    this.isTrusted = false,
    this.isRevoked = false,
  });

  factory DigitalCertificate.fromJson(Map<String, dynamic> json) =>
      _$DigitalCertificateFromJson(json);

  Map<String, dynamic> toJson() => _$DigitalCertificateToJson(this);

  DigitalCertificate copyWith({
    String? id,
    String? subjectName,
    String? issuerName,
    String? serialNumber,
    DateTime? validFrom,
    DateTime? validTo,
    CertificateType? type,
    String? email,
    String? organization,
    String? country,
    String? publicKey,
    Map<String, dynamic>? extensions,
    bool? isTrusted,
    bool? isRevoked,
  }) {
    return DigitalCertificate(
      id: id ?? this.id,
      subjectName: subjectName ?? this.subjectName,
      issuerName: issuerName ?? this.issuerName,
      serialNumber: serialNumber ?? this.serialNumber,
      validFrom: validFrom ?? this.validFrom,
      validTo: validTo ?? this.validTo,
      type: type ?? this.type,
      email: email ?? this.email,
      organization: organization ?? this.organization,
      country: country ?? this.country,
      publicKey: publicKey ?? this.publicKey,
      extensions: extensions ?? this.extensions,
      isTrusted: isTrusted ?? this.isTrusted,
      isRevoked: isRevoked ?? this.isRevoked,
    );
  }

  bool get isValid {
    final now = DateTime.now();
    return now.isAfter(validFrom) && now.isBefore(validTo) && !isRevoked;
  }

  bool get isExpired => DateTime.now().isAfter(validTo);
  bool get isSelfSigned => type == CertificateType.selfSigned;
  bool get isCASigned => type == CertificateType.caSigned;

  String get displayName {
    if (organization != null && organization!.isNotEmpty) {
      return '$subjectName ($organization)';
    }
    return subjectName;
  }

  String get validityStatus {
    if (isRevoked) return 'Revoked';
    if (isExpired) return 'Expired';
    if (!isValid) return 'Invalid';
    return 'Valid';
  }
}

@JsonSerializable()
class DigitalSignature {
  final String id;
  final String documentId;
  final String fieldName;
  final SignatureType type;
  final DigitalCertificate certificate;
  final String signatureValue;
  final String signatureAlgorithm;
  final DateTime signedAt;
  final String signerName;
  final String? signerEmail;
  final String? reason;
  final String? location;
  final String? contactInfo;
  final List<double> bounds; // [x, y, width, height]
  final int pageNumber;
  final SignatureStatus status;
  final String? statusMessage;
  final Map<String, dynamic> metadata;
  final bool isVisible;
  final String? signatureImage; // Base64 encoded signature image

  const DigitalSignature({
    required this.id,
    required this.documentId,
    required this.fieldName,
    required this.type,
    required this.certificate,
    required this.signatureValue,
    required this.signatureAlgorithm,
    required this.signedAt,
    required this.signerName,
    this.signerEmail,
    this.reason,
    this.location,
    this.contactInfo,
    required this.bounds,
    required this.pageNumber,
    required this.status,
    this.statusMessage,
    required this.metadata,
    this.isVisible = true,
    this.signatureImage,
  });

  factory DigitalSignature.fromJson(Map<String, dynamic> json) =>
      _$DigitalSignatureFromJson(json);

  Map<String, dynamic> toJson() => _$DigitalSignatureToJson(this);

  DigitalSignature copyWith({
    String? id,
    String? documentId,
    String? fieldName,
    SignatureType? type,
    DigitalCertificate? certificate,
    String? signatureValue,
    String? signatureAlgorithm,
    DateTime? signedAt,
    String? signerName,
    String? signerEmail,
    String? reason,
    String? location,
    String? contactInfo,
    List<double>? bounds,
    int? pageNumber,
    SignatureStatus? status,
    String? statusMessage,
    Map<String, dynamic>? metadata,
    bool? isVisible,
    String? signatureImage,
  }) {
    return DigitalSignature(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      fieldName: fieldName ?? this.fieldName,
      type: type ?? this.type,
      certificate: certificate ?? this.certificate,
      signatureValue: signatureValue ?? this.signatureValue,
      signatureAlgorithm: signatureAlgorithm ?? this.signatureAlgorithm,
      signedAt: signedAt ?? this.signedAt,
      signerName: signerName ?? this.signerName,
      signerEmail: signerEmail ?? this.signerEmail,
      reason: reason ?? this.reason,
      location: location ?? this.location,
      contactInfo: contactInfo ?? this.contactInfo,
      bounds: bounds ?? this.bounds,
      pageNumber: pageNumber ?? this.pageNumber,
      status: status ?? this.status,
      statusMessage: statusMessage ?? this.statusMessage,
      metadata: metadata ?? this.metadata,
      isVisible: isVisible ?? this.isVisible,
      signatureImage: signatureImage ?? this.signatureImage,
    );
  }

  bool get isValid => status == SignatureStatus.valid;
  bool get isInvalid => status == SignatureStatus.invalid;
  bool get isExpired => status == SignatureStatus.expired;
  bool get isRevoked => status == SignatureStatus.revoked;
  bool get isNotTrusted => status == SignatureStatus.notTrusted;

  String get statusDescription {
    switch (status) {
      case SignatureStatus.valid:
        return 'Valid signature';
      case SignatureStatus.invalid:
        return 'Invalid signature';
      case SignatureStatus.unknown:
        return 'Unknown signature status';
      case SignatureStatus.expired:
        return 'Signature expired';
      case SignatureStatus.revoked:
        return 'Signature revoked';
      case SignatureStatus.notTrusted:
        return 'Signature not trusted';
    }
  }

  String get displayInfo {
    final parts = <String>[];
    parts.add('Signed by: $signerName');
    if (reason != null && reason!.isNotEmpty) {
      parts.add('Reason: $reason');
    }
    if (location != null && location!.isNotEmpty) {
      parts.add('Location: $location');
    }
    parts.add('Date: ${signedAt.toLocal()}');
    parts.add('Status: $statusDescription');
    return parts.join('\n');
  }
}

@JsonSerializable()
class SignatureField {
  final String id;
  final String name;
  final String documentId;
  final int pageNumber;
  final List<double> bounds;
  final bool isRequired;
  final bool isSigned;
  final DigitalSignature? signature;
  final String? placeholder;
  final String? tooltip;
  final Map<String, dynamic> properties;

  const SignatureField({
    required this.id,
    required this.name,
    required this.documentId,
    required this.pageNumber,
    required this.bounds,
    this.isRequired = false,
    this.isSigned = false,
    this.signature,
    this.placeholder,
    this.tooltip,
    required this.properties,
  });

  factory SignatureField.fromJson(Map<String, dynamic> json) =>
      _$SignatureFieldFromJson(json);

  Map<String, dynamic> toJson() => _$SignatureFieldToJson(this);

  SignatureField copyWith({
    String? id,
    String? name,
    String? documentId,
    int? pageNumber,
    List<double>? bounds,
    bool? isRequired,
    bool? isSigned,
    DigitalSignature? signature,
    String? placeholder,
    String? tooltip,
    Map<String, dynamic>? properties,
  }) {
    return SignatureField(
      id: id ?? this.id,
      name: name ?? this.name,
      documentId: documentId ?? this.documentId,
      pageNumber: pageNumber ?? this.pageNumber,
      bounds: bounds ?? this.bounds,
      isRequired: isRequired ?? this.isRequired,
      isSigned: isSigned ?? this.isSigned,
      signature: signature ?? this.signature,
      placeholder: placeholder ?? this.placeholder,
      tooltip: tooltip ?? this.tooltip,
      properties: properties ?? this.properties,
    );
  }

  bool get hasValidSignature => signature?.isValid ?? false;
  bool get hasInvalidSignature => signature?.isInvalid ?? false;
  bool get needsSignature => isRequired && !isSigned;
}

@JsonSerializable()
class SignatureValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final List<DigitalSignature> invalidSignatures;
  final List<DigitalSignature> validSignatures;

  const SignatureValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
    required this.invalidSignatures,
    required this.validSignatures,
  });

  factory SignatureValidationResult.fromJson(Map<String, dynamic> json) =>
      _$SignatureValidationResultFromJson(json);

  Map<String, dynamic> toJson() => _$SignatureValidationResultToJson(this);

  SignatureValidationResult copyWith({
    bool? isValid,
    List<String>? errors,
    List<String>? warnings,
    List<DigitalSignature>? invalidSignatures,
    List<DigitalSignature>? validSignatures,
  }) {
    return SignatureValidationResult(
      isValid: isValid ?? this.isValid,
      errors: errors ?? this.errors,
      warnings: warnings ?? this.warnings,
      invalidSignatures: invalidSignatures ?? this.invalidSignatures,
      validSignatures: validSignatures ?? this.validSignatures,
    );
  }

  bool get hasErrors => errors.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasInvalidSignatures => invalidSignatures.isNotEmpty;
  bool get hasValidSignatures => validSignatures.isNotEmpty;
}
