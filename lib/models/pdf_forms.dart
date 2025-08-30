import 'package:json_annotation/json_annotation.dart';

part 'pdf_forms.g.dart';

enum FormFieldType {
  text,
  checkbox,
  radio,
  dropdown,
  signature,
  date,
  number,
  email,
  url,
  password,
}

enum FormFieldState {
  normal,
  readonly,
  required,
  hidden,
}

@JsonSerializable()
class PdfFormField {
  final String id;
  final String name;
  final FormFieldType type;
  final FormFieldState state;
  final String? value;
  final String? defaultValue;
  final String? placeholder;
  final String? label;
  final String? tooltip;
  final List<double> bounds; // [x, y, width, height]
  final int pageNumber;
  final Map<String, dynamic> properties;
  final List<String>? options; // For dropdown/radio fields
  final bool isRequired;
  final String? validationPattern;
  final String? errorMessage;

  const PdfFormField({
    required this.id,
    required this.name,
    required this.type,
    required this.state,
    this.value,
    this.defaultValue,
    this.placeholder,
    this.label,
    this.tooltip,
    required this.bounds,
    required this.pageNumber,
    required this.properties,
    this.options,
    this.isRequired = false,
    this.validationPattern,
    this.errorMessage,
  });

  factory PdfFormField.fromJson(Map<String, dynamic> json) =>
      _$PdfFormFieldFromJson(json);

  Map<String, dynamic> toJson() => _$PdfFormFieldToJson(this);

  PdfFormField copyWith({
    String? id,
    String? name,
    FormFieldType? type,
    FormFieldState? state,
    String? value,
    String? defaultValue,
    String? placeholder,
    String? label,
    String? tooltip,
    List<double>? bounds,
    int? pageNumber,
    Map<String, dynamic>? properties,
    List<String>? options,
    bool? isRequired,
    String? validationPattern,
    String? errorMessage,
  }) {
    return PdfFormField(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      state: state ?? this.state,
      value: value ?? this.value,
      defaultValue: defaultValue ?? this.defaultValue,
      placeholder: placeholder ?? this.placeholder,
      label: label ?? this.label,
      tooltip: tooltip ?? this.tooltip,
      bounds: bounds ?? this.bounds,
      pageNumber: pageNumber ?? this.pageNumber,
      properties: properties ?? this.properties,
      options: options ?? this.options,
      isRequired: isRequired ?? this.isRequired,
      validationPattern: validationPattern ?? this.validationPattern,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isReadOnly => state == FormFieldState.readonly;
  bool get isHidden => state == FormFieldState.hidden;
  bool get hasValue => value != null && value!.isNotEmpty;
  bool get isValid => _validateField();

  bool _validateField() {
    if (isRequired && (value == null || value!.isEmpty)) {
      return false;
    }

    if (validationPattern != null && value != null && value!.isNotEmpty) {
      final regex = RegExp(validationPattern!);
      return regex.hasMatch(value!);
    }

    return true;
  }

  String? getValidationError() {
    if (isRequired && (value == null || value!.isEmpty)) {
      return errorMessage ?? 'This field is required';
    }

    if (validationPattern != null && value != null && value!.isNotEmpty) {
      final regex = RegExp(validationPattern!);
      if (!regex.hasMatch(value!)) {
        return errorMessage ?? 'Invalid format';
      }
    }

    return null;
  }
}

@JsonSerializable()
class PdfForm {
  final String id;
  final String name;
  final String documentId;
  final List<PdfFormField> fields;
  final bool isEditable;
  final bool isSigned;
  final DateTime? createdAt;
  final DateTime? modifiedAt;
  final Map<String, dynamic> metadata;

  const PdfForm({
    required this.id,
    required this.name,
    required this.documentId,
    required this.fields,
    this.isEditable = true,
    this.isSigned = false,
    this.createdAt,
    this.modifiedAt,
    required this.metadata,
  });

  factory PdfForm.fromJson(Map<String, dynamic> json) =>
      _$PdfFormFromJson(json);

  Map<String, dynamic> toJson() => _$PdfFormToJson(this);

  PdfForm copyWith({
    String? id,
    String? name,
    String? documentId,
    List<PdfFormField>? fields,
    bool? isEditable,
    bool? isSigned,
    DateTime? createdAt,
    DateTime? modifiedAt,
    Map<String, dynamic>? metadata,
  }) {
    return PdfForm(
      id: id ?? this.id,
      name: name ?? this.name,
      documentId: documentId ?? this.documentId,
      fields: fields ?? this.fields,
      isEditable: isEditable ?? this.isEditable,
      isSigned: isSigned ?? this.isSigned,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  List<PdfFormField> getFieldsForPage(int pageNumber) {
    return fields.where((field) => field.pageNumber == pageNumber).toList();
  }

  List<PdfFormField> getRequiredFields() {
    return fields.where((field) => field.isRequired).toList();
  }

  List<PdfFormField> getInvalidFields() {
    return fields.where((field) => !field.isValid).toList();
  }

  bool get isComplete {
    return getRequiredFields().every((field) => field.isValid);
  }

  bool get hasChanges {
    return fields.any((field) => field.value != field.defaultValue);
  }

  Map<String, String> getFieldValues() {
    final values = <String, String>{};
    for (final field in fields) {
      if (field.hasValue) {
        values[field.name] = field.value!;
      }
    }
    return values;
  }

  void setFieldValue(String fieldName, String value) {
    final fieldIndex = fields.indexWhere((field) => field.name == fieldName);
    if (fieldIndex != -1) {
      fields[fieldIndex] = fields[fieldIndex].copyWith(value: value);
    }
  }

  void resetToDefaults() {
    for (int i = 0; i < fields.length; i++) {
      fields[i] = fields[i].copyWith(value: fields[i].defaultValue);
    }
  }

  void clearAllFields() {
    for (int i = 0; i < fields.length; i++) {
      fields[i] = fields[i].copyWith(value: '');
    }
  }
}

@JsonSerializable()
class FormValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<PdfFormField> invalidFields;

  const FormValidationResult({
    required this.isValid,
    required this.errors,
    required this.invalidFields,
  });

  factory FormValidationResult.fromJson(Map<String, dynamic> json) =>
      _$FormValidationResultFromJson(json);

  Map<String, dynamic> toJson() => _$FormValidationResultToJson(this);

  FormValidationResult copyWith({
    bool? isValid,
    List<String>? errors,
    List<PdfFormField>? invalidFields,
  }) {
    return FormValidationResult(
      isValid: isValid ?? this.isValid,
      errors: errors ?? this.errors,
      invalidFields: invalidFields ?? this.invalidFields,
    );
  }
}
