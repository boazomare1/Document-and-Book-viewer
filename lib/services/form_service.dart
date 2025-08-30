import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/pdf_forms.dart';
import 'package:uuid/uuid.dart';

class FormService {
  static final FormService _instance = FormService._internal();
  factory FormService() => _instance;
  FormService._internal();

  final Uuid _uuid = const Uuid();

  // Extract form fields from PDF (simplified version)
  Future<PdfForm> extractFormFields(String pdfPath) async {
    try {
      // In a real implementation, you would use Syncfusion PDF library
      // For now, return a placeholder form
      final String documentId = _uuid.v4();

      return PdfForm(
        id: _uuid.v4(),
        name: 'Form from ${pdfPath.split('/').last}',
        documentId: documentId,
        fields: [], // Empty for now
        metadata: {
          'source': pdfPath,
          'extractedAt': DateTime.now().toIso8601String(),
          'fieldCount': 0,
          'note': 'Form extraction not implemented yet',
        },
      );
    } catch (e) {
      throw Exception('Failed to extract form fields: $e');
    }
  }

  // Check if PDF has forms (simplified version)
  Future<bool> hasForms(String pdfPath) async {
    try {
      // In a real implementation, you would check the PDF for form fields
      // For now, return false
      return false;
    } catch (e) {
      return false;
    }
  }

  // Export form data to CSV
  Future<String> exportFormDataToCsv(PdfForm form) async {
    try {
      final StringBuffer csv = StringBuffer();
      csv.writeln('Name,Type,Value,Required,Page');

      for (final field in form.fields) {
        csv.writeln(
          '${field.name},${field.type},${field.value ?? ""},${field.isRequired},${field.pageNumber}',
        );
      }

      return csv.toString();
    } catch (e) {
      throw Exception('Failed to export form data: $e');
    }
  }

  // Import form data from JSON
  Future<PdfForm> importFormDataFromJson(String jsonData) async {
    try {
      final Map<String, dynamic> data = json.decode(jsonData);

      final List<dynamic> fieldsData = data['fields'] as List;

      final List<PdfFormField> fields =
          fieldsData.map((fieldData) {
            return PdfFormField.fromJson(fieldData as Map<String, dynamic>);
          }).toList();

      return PdfForm(
        id: data['id'] ?? _uuid.v4(),
        name: data['name'] ?? 'Imported Form',
        documentId: data['documentId'] ?? _uuid.v4(),
        fields: fields,
        metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      );
    } catch (e) {
      throw Exception('Failed to import form data: $e');
    }
  }

  // Validate form data
  Future<List<String>> validateFormData(PdfForm form) async {
    final List<String> errors = [];

    for (final field in form.fields) {
      if (field.isRequired && (field.value == null || field.value!.isEmpty)) {
        errors.add('Required field "${field.name}" is empty');
      }
    }

    return errors;
  }

  // Get form statistics
  Future<FormStatistics> getFormStatistics(PdfForm form) async {
    int textFields = 0;
    int checkboxes = 0;
    int radioButtons = 0;
    int dropdowns = 0;
    int requiredFields = 0;
    int filledFields = 0;

    for (final field in form.fields) {
      switch (field.type) {
        case FormFieldType.text:
          textFields++;
          break;
        case FormFieldType.checkbox:
          checkboxes++;
          break;
        case FormFieldType.radio:
          radioButtons++;
          break;
        case FormFieldType.dropdown:
          dropdowns++;
          break;
        default:
          textFields++;
      }

      if (field.isRequired) {
        requiredFields++;
      }

      if (field.value != null && field.value!.isNotEmpty) {
        filledFields++;
      }
    }

    return FormStatistics(
      totalFields: form.fields.length,
      textFields: textFields,
      checkboxes: checkboxes,
      radioButtons: radioButtons,
      dropdowns: dropdowns,
      requiredFields: requiredFields,
      filledFields: filledFields,
      completionRate:
          form.fields.isNotEmpty
              ? (filledFields / form.fields.length) * 100
              : 0.0,
    );
  }
}

class FormStatistics {
  final int totalFields;
  final int textFields;
  final int checkboxes;
  final int radioButtons;
  final int dropdowns;
  final int requiredFields;
  final int filledFields;
  final double completionRate;

  const FormStatistics({
    required this.totalFields,
    required this.textFields,
    required this.checkboxes,
    required this.radioButtons,
    required this.dropdowns,
    required this.requiredFields,
    required this.filledFields,
    required this.completionRate,
  });
}
