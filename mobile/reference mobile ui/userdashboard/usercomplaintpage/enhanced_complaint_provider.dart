import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobileapplication/userdashboard/usercomplaintpage/services/location_service.dart';
import 'package:mobileapplication/userdashboard/usercomplaintpage/services/file_upload_service.dart';
import 'package:mobileapplication/userdashboard/usercomplaintpage/firestore_service.dart';
import 'package:mobileapplication/userdashboard/usercomplaintpage/complaint_success_modal.dart';

class EnhancedComplaintProvider extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final LocationService _locationService = LocationService();
  final FileUploadService _fileService = FileUploadService();

  // Form fields
  String _name = '';
  DateTime? _dateOfBirth;
  String _phone = '';
  String _email = '';
  String? _address;
  String _complaint = '';

  // New compact design fields
  String? _incidentType;
  String? _briefDescription;
  String? _locationText;

  // Professional report fields
  String? _priority;
  String? _weatherConditions;
  String? _visibility;
  String? _organization;
  String? _environmentalImpact;
  String? _safetyRisk;
  String? _economicImpact;
  String? _legalRisk;
  String? _recommendedAction;
  String? _reportStatus;
  String? _confidentiality;

  // State management
  bool _isSubmitting = false;
  String? _message;
  bool _isError = false;
  bool _isLocationLoading = false;
  bool _isFileUploading = false;

  // Getters
  String get name => _name;
  DateTime? get dateOfBirth => _dateOfBirth;
  String get phone => _phone;
  String get email => _email;
  String? get address => _address;
  String get complaint => _complaint;
  String? get incidentType => _incidentType;
  String? get briefDescription => _briefDescription;
  String? get locationText => _locationText;

  // Professional report getters
  String? get priority => _priority;
  String? get weatherConditions => _weatherConditions;
  String? get visibility => _visibility;
  String? get organization => _organization;
  String? get environmentalImpact => _environmentalImpact;
  String? get safetyRisk => _safetyRisk;
  String? get economicImpact => _economicImpact;
  String? get legalRisk => _legalRisk;
  String? get recommendedAction => _recommendedAction;
  String? get reportStatus => _reportStatus;
  String? get confidentiality => _confidentiality;

  bool get isSubmitting => _isSubmitting;
  bool get isLocationLoading => _isLocationLoading;
  bool get isFileUploading => _isFileUploading;
  String? get message => _message;
  bool get isError => _isError;
  List<FileUploadItem> get uploadedFiles => _fileService.uploadedFiles;

  // Update methods
  void updateField(String field, dynamic value) {
    switch (field) {
      case 'name':
        _name = value;
        break;
      case 'dateOfBirth':
        _dateOfBirth = value;
        break;
      case 'phone':
        _phone = value;
        break;
      case 'email':
        _email = value;
        break;
      case 'address':
        _address = value;
        break;
      case 'complaint':
        _complaint = value;
        break;
    }
    notifyListeners();
  }

  void updateIncidentType(String? type) {
    _incidentType = type;
    notifyListeners();
  }

  void updateBriefDescription(String? description) {
    _briefDescription = description;
    notifyListeners();
  }

  void updateLocationText(String? location) {
    _locationText = location;
    notifyListeners();
  }

  // Professional report update methods
  void updatePriority(String? priority) {
    _priority = priority;
    notifyListeners();
  }

  void updateWeatherConditions(String? weather) {
    _weatherConditions = weather;
    notifyListeners();
  }

  void updateVisibility(String? visibility) {
    _visibility = visibility;
    notifyListeners();
  }

  void updateOrganization(String? organization) {
    _organization = organization;
    notifyListeners();
  }

  void updateEnvironmentalImpact(String? impact) {
    _environmentalImpact = impact;
    notifyListeners();
  }

  void updateSafetyRisk(String? risk) {
    _safetyRisk = risk;
    notifyListeners();
  }

  void updateEconomicImpact(String? impact) {
    _economicImpact = impact;
    notifyListeners();
  }

  void updateLegalRisk(String? risk) {
    _legalRisk = risk;
    notifyListeners();
  }

  void updateRecommendedAction(String? action) {
    _recommendedAction = action;
    notifyListeners();
  }

  void updateReportStatus(String? status) {
    _reportStatus = status;
    notifyListeners();
  }

  void updateConfidentiality(String? confidentiality) {
    _confidentiality = confidentiality;
    notifyListeners();
  }

  // Location management
  Future<void> initializeLocation() async {
    _isLocationLoading = true;
    _message = null;
    _isError = false;
    notifyListeners();

    try {
      // Initialize service (check permissions and location services)
      final initialized = await _locationService.initialize();
      if (!initialized) {
        // Even if initialize fails, try getCurrentLocation which will handle permissions more robustly
        debugPrint('⚠️ Location service initialization returned false, but attempting to get location anyway...');
      }

      // Get current location (this method now handles permission re-checking internally)
      final result = await _locationService.getCurrentLocation();
      if (result.isSuccess) {
        _locationText = result.address;
        _address = result.address;
        _message = 'Location detected successfully';
        _isError = false;
        debugPrint('✅ Location obtained: $_locationText');
      } else {
        _message = result.error ?? 'Failed to get location';
        _isError = true;
        debugPrint('❌ Location error: ${result.error}');
      }
    } catch (e) {
      _message = 'Location error: ${e.toString()}';
      _isError = true;
      debugPrint('❌ Location exception: $e');
    } finally {
      _isLocationLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshLocation() async {
    await initializeLocation();
  }

  // File management
  Future<void> pickImage(ImageSource source) async {
    try {
      final result = await _fileService.pickImage(source);
      if (result.isSuccess && result.item != null) {
        _message = 'Image added successfully';
        _isError = false;
      } else if (result.isCancelled) {
        // User cancelled, no error
        return;
      } else {
        _message = result.error ?? 'Failed to add image';
        _isError = true;
      }
    } catch (e) {
      _message = 'Image picker error: $e';
      _isError = true;
    }
    notifyListeners();
  }

  Future<void> pickVideo(ImageSource source) async {
    try {
      final result = await _fileService.pickVideo(source);
      if (result.isSuccess && result.item != null) {
        _message = 'Video added successfully';
        _isError = false;
      } else if (result.isCancelled) {
        return;
      } else {
        _message = result.error ?? 'Failed to add video';
        _isError = true;
      }
    } catch (e) {
      _message = 'Video picker error: $e';
      _isError = true;
    }
    notifyListeners();
  }

  /// Replace existing image with a new one
  Future<void> replaceImage(ImageSource source) async {
    try {
      final result = await _fileService.replaceImage(source);
      if (result.isSuccess && result.item != null) {
        _message = 'Photo changed successfully';
        _isError = false;
      } else if (result.isCancelled) {
        // User cancelled, no error
        return;
      } else {
        _message = result.error ?? 'Failed to change photo';
        _isError = true;
      }
    } catch (e) {
      _message = 'Failed to change photo: $e';
      _isError = true;
    }
    notifyListeners();
  }

  /// Replace existing video with a new one
  Future<void> replaceVideo(ImageSource source) async {
    try {
      final result = await _fileService.replaceVideo(source);
      if (result.isSuccess && result.item != null) {
        _message = 'Video changed successfully';
        _isError = false;
      } else if (result.isCancelled) {
        // User cancelled, no error
        return;
      } else {
        _message = result.error ?? 'Failed to change video';
        _isError = true;
      }
    } catch (e) {
      _message = 'Failed to change video: $e';
      _isError = true;
    }
    notifyListeners();
  }

  void removeFile(int index) {
    _fileService.removeFile(index);
    notifyListeners();
  }

  // Form submission
  Future<String?> submitComplaint(BuildContext context) async {
    if (!formKey.currentState!.validate()) return null;

    formKey.currentState!.save();

    try {
      setSubmitting(true);

      // Validate required fields
      if (_name.isEmpty) {
        _message = 'Name is required';
        _isError = true;
        return null;
      }
      if (_phone.isEmpty) {
        _message = 'Phone number is required';
        _isError = true;
        return null;
      }
      if (_email.isEmpty) {
        _message = 'Email is required';
        _isError = true;
        return null;
      }
      if (_dateOfBirth == null) {
        _message = 'Date of birth is required';
        _isError = true;
        return null;
      }
      if (_complaint.isEmpty) {
        _message = 'Complaint description is required';
        _isError = true;
        return null;
      }

      // Ensure location is available
      if (_locationText == null || _locationText!.isEmpty) {
        await initializeLocation();
        if (_locationText == null || _locationText!.isEmpty) {
          _message = 'Location is required for complaint submission';
          _isError = true;
          return null;
        }
      }

      // Upload files
      _isFileUploading = true;
      notifyListeners();

      final uploadResult = await _fileService.uploadAllFiles();
      if (!uploadResult.isSuccess) {
        _message = uploadResult.error ?? 'Failed to upload files';
        _isError = true;
        return null;
      }

      // Submit to Firestore
      final complaintId = await FirestoreService.createComplaint(
        name: _name,
        dateOfBirth: _dateOfBirth!,
        phone: _phone,
        email: _email,
        address: _address ?? _locationText ?? 'Unknown location',
        complaint: _complaint,
        attachedFiles: uploadResult.urls,
      );

      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return ComplaintSuccessModal(
              complaintNumber: complaintId,
              onDismissed: () async {
                await clearForm();
              },
            );
          },
        );
      }

      return complaintId;
    } catch (e) {
      _message = 'Failed to submit complaint: $e';
      _isError = true;
      return null;
    } finally {
      setSubmitting(false);
      _isFileUploading = false;
      notifyListeners();
    }
  }

  void setSubmitting(bool submitting) {
    _isSubmitting = submitting;
    notifyListeners();
  }

  Future<void> clearForm() async {
    formKey.currentState?.reset();
    _name = '';
    _dateOfBirth = null;
    _phone = '';
    _email = '';
    _address = null;
    _complaint = '';
    _incidentType = null;
    _briefDescription = null;
    _locationText = null;
    _message = null;
    _isError = false;
    await _fileService.clearAllFiles();
    _locationService.clearLocation();
    notifyListeners();
  }

  // Legacy methods for compatibility
  void updateName(String value) => updateField('name', value);
  void updateDateOfBirth(DateTime value) => updateField('dateOfBirth', value);
  void updatePhone(String value) => updateField('phone', value);
  void updateEmail(String value) => updateField('email', value);
  void updateAddress(String value) => updateField('address', value);
  void updateComplaint(String value) => updateField('complaint', value);

  // Legacy getters for compatibility
  List<File> get attachedFiles =>
      _fileService.uploadedFiles.map((item) => item.file).toList();
  Position? get location => _locationService.currentPosition;

  // Legacy methods for compatibility
  void addFile(File file) {
    // This is a simplified version for compatibility
    // In practice, you'd want to use the FileUploadService methods
  }

  Future<void> updateLocation() async {
    await initializeLocation();
  }

  bool validateAllFields() {
    return formKey.currentState?.validate() ?? false;
  }

  /// Auto-fill form with user data from settings
  void autoFillForm({
    String? name,
    String? email,
    String? phone,
    DateTime? dateOfBirth,
  }) {
    if (name != null && name.isNotEmpty) {
      _name = name;
    }
    if (email != null && email.isNotEmpty) {
      _email = email;
    }
    if (phone != null && phone.isNotEmpty) {
      _phone = phone;
    }
    if (dateOfBirth != null) {
      _dateOfBirth = dateOfBirth;
    }
    notifyListeners();
  }
}
