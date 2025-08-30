// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'digital_signatures.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DigitalCertificate _$DigitalCertificateFromJson(Map<String, dynamic> json) =>
    DigitalCertificate(
      id: json['id'] as String,
      subjectName: json['subjectName'] as String,
      issuerName: json['issuerName'] as String,
      serialNumber: json['serialNumber'] as String,
      validFrom: DateTime.parse(json['validFrom'] as String),
      validTo: DateTime.parse(json['validTo'] as String),
      type: $enumDecode(_$CertificateTypeEnumMap, json['type']),
      email: json['email'] as String?,
      organization: json['organization'] as String?,
      country: json['country'] as String?,
      publicKey: json['publicKey'] as String?,
      extensions: json['extensions'] as Map<String, dynamic>,
      isTrusted: json['isTrusted'] as bool? ?? false,
      isRevoked: json['isRevoked'] as bool? ?? false,
    );

Map<String, dynamic> _$DigitalCertificateToJson(DigitalCertificate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'subjectName': instance.subjectName,
      'issuerName': instance.issuerName,
      'serialNumber': instance.serialNumber,
      'validFrom': instance.validFrom.toIso8601String(),
      'validTo': instance.validTo.toIso8601String(),
      'type': _$CertificateTypeEnumMap[instance.type]!,
      'email': instance.email,
      'organization': instance.organization,
      'country': instance.country,
      'publicKey': instance.publicKey,
      'extensions': instance.extensions,
      'isTrusted': instance.isTrusted,
      'isRevoked': instance.isRevoked,
    };

const _$CertificateTypeEnumMap = {
  CertificateType.selfSigned: 'selfSigned',
  CertificateType.caSigned: 'caSigned',
  CertificateType.codeSigning: 'codeSigning',
  CertificateType.email: 'email',
  CertificateType.documentSigning: 'documentSigning',
};

DigitalSignature _$DigitalSignatureFromJson(Map<String, dynamic> json) =>
    DigitalSignature(
      id: json['id'] as String,
      documentId: json['documentId'] as String,
      fieldName: json['fieldName'] as String,
      type: $enumDecode(_$SignatureTypeEnumMap, json['type']),
      certificate: DigitalCertificate.fromJson(
        json['certificate'] as Map<String, dynamic>,
      ),
      signatureValue: json['signatureValue'] as String,
      signatureAlgorithm: json['signatureAlgorithm'] as String,
      signedAt: DateTime.parse(json['signedAt'] as String),
      signerName: json['signerName'] as String,
      signerEmail: json['signerEmail'] as String?,
      reason: json['reason'] as String?,
      location: json['location'] as String?,
      contactInfo: json['contactInfo'] as String?,
      bounds:
          (json['bounds'] as List<dynamic>)
              .map((e) => (e as num).toDouble())
              .toList(),
      pageNumber: (json['pageNumber'] as num).toInt(),
      status: $enumDecode(_$SignatureStatusEnumMap, json['status']),
      statusMessage: json['statusMessage'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>,
      isVisible: json['isVisible'] as bool? ?? true,
      signatureImage: json['signatureImage'] as String?,
    );

Map<String, dynamic> _$DigitalSignatureToJson(DigitalSignature instance) =>
    <String, dynamic>{
      'id': instance.id,
      'documentId': instance.documentId,
      'fieldName': instance.fieldName,
      'type': _$SignatureTypeEnumMap[instance.type]!,
      'certificate': instance.certificate,
      'signatureValue': instance.signatureValue,
      'signatureAlgorithm': instance.signatureAlgorithm,
      'signedAt': instance.signedAt.toIso8601String(),
      'signerName': instance.signerName,
      'signerEmail': instance.signerEmail,
      'reason': instance.reason,
      'location': instance.location,
      'contactInfo': instance.contactInfo,
      'bounds': instance.bounds,
      'pageNumber': instance.pageNumber,
      'status': _$SignatureStatusEnumMap[instance.status]!,
      'statusMessage': instance.statusMessage,
      'metadata': instance.metadata,
      'isVisible': instance.isVisible,
      'signatureImage': instance.signatureImage,
    };

const _$SignatureTypeEnumMap = {
  SignatureType.digital: 'digital',
  SignatureType.electronic: 'electronic',
  SignatureType.timestamp: 'timestamp',
  SignatureType.approval: 'approval',
  SignatureType.certification: 'certification',
};

const _$SignatureStatusEnumMap = {
  SignatureStatus.valid: 'valid',
  SignatureStatus.invalid: 'invalid',
  SignatureStatus.unknown: 'unknown',
  SignatureStatus.expired: 'expired',
  SignatureStatus.revoked: 'revoked',
  SignatureStatus.notTrusted: 'notTrusted',
};

SignatureField _$SignatureFieldFromJson(Map<String, dynamic> json) =>
    SignatureField(
      id: json['id'] as String,
      name: json['name'] as String,
      documentId: json['documentId'] as String,
      pageNumber: (json['pageNumber'] as num).toInt(),
      bounds:
          (json['bounds'] as List<dynamic>)
              .map((e) => (e as num).toDouble())
              .toList(),
      isRequired: json['isRequired'] as bool? ?? false,
      isSigned: json['isSigned'] as bool? ?? false,
      signature:
          json['signature'] == null
              ? null
              : DigitalSignature.fromJson(
                json['signature'] as Map<String, dynamic>,
              ),
      placeholder: json['placeholder'] as String?,
      tooltip: json['tooltip'] as String?,
      properties: json['properties'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$SignatureFieldToJson(SignatureField instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'documentId': instance.documentId,
      'pageNumber': instance.pageNumber,
      'bounds': instance.bounds,
      'isRequired': instance.isRequired,
      'isSigned': instance.isSigned,
      'signature': instance.signature,
      'placeholder': instance.placeholder,
      'tooltip': instance.tooltip,
      'properties': instance.properties,
    };

SignatureValidationResult _$SignatureValidationResultFromJson(
  Map<String, dynamic> json,
) => SignatureValidationResult(
  isValid: json['isValid'] as bool,
  errors: (json['errors'] as List<dynamic>).map((e) => e as String).toList(),
  warnings:
      (json['warnings'] as List<dynamic>).map((e) => e as String).toList(),
  invalidSignatures:
      (json['invalidSignatures'] as List<dynamic>)
          .map((e) => DigitalSignature.fromJson(e as Map<String, dynamic>))
          .toList(),
  validSignatures:
      (json['validSignatures'] as List<dynamic>)
          .map((e) => DigitalSignature.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$SignatureValidationResultToJson(
  SignatureValidationResult instance,
) => <String, dynamic>{
  'isValid': instance.isValid,
  'errors': instance.errors,
  'warnings': instance.warnings,
  'invalidSignatures': instance.invalidSignatures,
  'validSignatures': instance.validSignatures,
};
