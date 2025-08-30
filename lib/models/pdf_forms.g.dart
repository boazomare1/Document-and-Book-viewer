// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdf_forms.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PdfFormField _$PdfFormFieldFromJson(Map<String, dynamic> json) => PdfFormField(
  id: json['id'] as String,
  name: json['name'] as String,
  type: $enumDecode(_$FormFieldTypeEnumMap, json['type']),
  state: $enumDecode(_$FormFieldStateEnumMap, json['state']),
  value: json['value'] as String?,
  defaultValue: json['defaultValue'] as String?,
  placeholder: json['placeholder'] as String?,
  label: json['label'] as String?,
  tooltip: json['tooltip'] as String?,
  bounds:
      (json['bounds'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
  pageNumber: (json['pageNumber'] as num).toInt(),
  properties: json['properties'] as Map<String, dynamic>,
  options:
      (json['options'] as List<dynamic>?)?.map((e) => e as String).toList(),
  isRequired: json['isRequired'] as bool? ?? false,
  validationPattern: json['validationPattern'] as String?,
  errorMessage: json['errorMessage'] as String?,
);

Map<String, dynamic> _$PdfFormFieldToJson(PdfFormField instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$FormFieldTypeEnumMap[instance.type]!,
      'state': _$FormFieldStateEnumMap[instance.state]!,
      'value': instance.value,
      'defaultValue': instance.defaultValue,
      'placeholder': instance.placeholder,
      'label': instance.label,
      'tooltip': instance.tooltip,
      'bounds': instance.bounds,
      'pageNumber': instance.pageNumber,
      'properties': instance.properties,
      'options': instance.options,
      'isRequired': instance.isRequired,
      'validationPattern': instance.validationPattern,
      'errorMessage': instance.errorMessage,
    };

const _$FormFieldTypeEnumMap = {
  FormFieldType.text: 'text',
  FormFieldType.checkbox: 'checkbox',
  FormFieldType.radio: 'radio',
  FormFieldType.dropdown: 'dropdown',
  FormFieldType.signature: 'signature',
  FormFieldType.date: 'date',
  FormFieldType.number: 'number',
  FormFieldType.email: 'email',
  FormFieldType.url: 'url',
  FormFieldType.password: 'password',
};

const _$FormFieldStateEnumMap = {
  FormFieldState.normal: 'normal',
  FormFieldState.readonly: 'readonly',
  FormFieldState.required: 'required',
  FormFieldState.hidden: 'hidden',
};

PdfForm _$PdfFormFromJson(Map<String, dynamic> json) => PdfForm(
  id: json['id'] as String,
  name: json['name'] as String,
  documentId: json['documentId'] as String,
  fields:
      (json['fields'] as List<dynamic>)
          .map((e) => PdfFormField.fromJson(e as Map<String, dynamic>))
          .toList(),
  isEditable: json['isEditable'] as bool? ?? true,
  isSigned: json['isSigned'] as bool? ?? false,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  modifiedAt:
      json['modifiedAt'] == null
          ? null
          : DateTime.parse(json['modifiedAt'] as String),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$PdfFormToJson(PdfForm instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'documentId': instance.documentId,
  'fields': instance.fields,
  'isEditable': instance.isEditable,
  'isSigned': instance.isSigned,
  'createdAt': instance.createdAt?.toIso8601String(),
  'modifiedAt': instance.modifiedAt?.toIso8601String(),
  'metadata': instance.metadata,
};

FormValidationResult _$FormValidationResultFromJson(
  Map<String, dynamic> json,
) => FormValidationResult(
  isValid: json['isValid'] as bool,
  errors: (json['errors'] as List<dynamic>).map((e) => e as String).toList(),
  invalidFields:
      (json['invalidFields'] as List<dynamic>)
          .map((e) => PdfFormField.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$FormValidationResultToJson(
  FormValidationResult instance,
) => <String, dynamic>{
  'isValid': instance.isValid,
  'errors': instance.errors,
  'invalidFields': instance.invalidFields,
};
