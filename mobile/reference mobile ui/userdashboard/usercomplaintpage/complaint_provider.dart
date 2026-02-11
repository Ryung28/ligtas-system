import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobileapplication/services/cloudinary_service.dart';
import 'package:mobileapplication/userdashboard/usercomplaintpage/firestore_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobileapplication/userdashboard/usercomplaintpage/complaint_success_modal.dart';

class ComplaintFormProvider extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  String _name = '';
  DateTime? _dateOfBirth;
  String _phone = '';
  String _email = '';
  String? _address;
  String _complaint = '';
  List<File> _attachedFiles = [];
  bool _isSubmitting = false;
  String? _message;
  bool _isError = false;
  Position? _location;

  // New fields for compact design
  String? _incidentType;
  String? _briefDescription;
  String? _locationText;

  String get name => _name;
  DateTime? get dateOfBirth => _dateOfBirth;
  String get phone => _phone;
  String get email => _email;
  String? get address => _address;
  String get complaint => _complaint;
  List<File> get attachedFiles => _attachedFiles;
  bool get isSubmitting => _isSubmitting;
  String? get message => _message;
  bool get isError => _isError;
  Position? get location => _location;

  // New getters
  String? get incidentType => _incidentType;
  String? get briefDescription => _briefDescription;
  String? get locationText => _locationText;

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

  void setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }

  // File handling methods
  Future<void> pickFile(ImageSource source, {bool isVideo = false}) async {
    try {
      final XFile? file = isVideo
          ? await _picker.pickVideo(source: source)
          : await _picker.pickImage(source: source);
      if (file != null) {
        _attachedFiles.add(File(file.path));
        notifyListeners();
      }
    } catch (e) {
      _message = 'Failed to pick file: $e';
      _isError = true;
      notifyListeners();
    }
  }

  void removeFile(int index) {
    if (index >= 0 && index < _attachedFiles.length) {
      _attachedFiles.removeAt(index);
      notifyListeners();
    }
  }

  void addFile(File file) {
    _attachedFiles.add(file);
    notifyListeners();
  }

  bool validateAllFields() {
    if (!formKey.currentState!.validate()) return false;

    final isValid = _name.isNotEmpty &&
        _dateOfBirth != null &&
        _phone.isNotEmpty &&
        _email.isNotEmpty &&
        _address != null &&
        _complaint.isNotEmpty;

    if (!isValid) {
      _message = 'Please fill in all required fields';
      _isError = true;
      notifyListeners();
    }

    return isValid;
  }

  Future<void> updateLocation() async {
    try {
      _location = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Convert coordinates to address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _location!.latitude,
        _location!.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        _address =
            '${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}';
      }

      notifyListeners();
    } catch (e) {
      _message = 'Failed to get location: $e';
      _isError = true;
      notifyListeners();
    }
  }

  Future<String?> submitComplaint(BuildContext context) async {
    if (!formKey.currentState!.validate()) return null;

    formKey.currentState!.save();

    try {
      setSubmitting(true);

      // Ensure location is updated
      await updateLocation();

      // Upload files to Cloudinary
      List<String> fileUrls = [];
      if (_attachedFiles.isNotEmpty) {
        fileUrls =
            await CloudinaryService.uploadFiles(_attachedFiles, 'complaints');
      }

      // Submit to Firestore
      final complaintId = await FirestoreService.createComplaint(
        name: _name,
        dateOfBirth: _dateOfBirth!,
        phone: _phone,
        email: _email,
        address: _address ?? 'Unknown location',
        complaint: _complaint,
        attachedFiles: fileUrls,
      );

      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return ComplaintSuccessModal(
              complaintNumber: complaintId,
              onDismissed: () {
                // Add any additional actions to perform when user dismisses the dialog
              },
            );
          },
        );

        // Clear form
        clearForm();
        if (context.mounted) {
          _name = '';
          _dateOfBirth = null;
          _phone = '';
          _email = '';
          _address = '';
          _complaint = '';
          _attachedFiles = [];
          _location = null;
          formKey.currentState?.reset();
          notifyListeners();
        }
      }

      return complaintId;
    } catch (e) {
      _message = 'Failed to submit complaint: $e';
      _isError = true;
      notifyListeners();
      return null;
    } finally {
      setSubmitting(false);
    }
  }

  void clearForm() {
    formKey.currentState?.reset();
    _name = '';
    _dateOfBirth = null;
    _phone = '';
    _email = '';
    _address = null;
    _complaint = '';
    _attachedFiles = [];
    _message = null;
    _isError = false;
    notifyListeners();
  }

  // Add these methods alongside other update methods
  void updateName(String value) => updateField('name', value);
  void updateDateOfBirth(DateTime value) => updateField('dateOfBirth', value);
  void updatePhone(String value) => updateField('phone', value);
  void updateEmail(String value) => updateField('email', value);
  void updateAddress(String value) => updateField('address', value);
  void updateComplaint(String value) => updateField('complaint', value);

  // New update methods for compact design
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
}

class ReportPage extends StatelessWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Management'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // OPTIMIZED: Add limit to real-time listener to prevent excessive reads
        stream: FirebaseFirestore.instance
            .collection('complaints')
            .orderBy('createdAt', descending: true)
            .limit(50) // DEFAULT LIMIT: Prevents fetching all complaints
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final complaints = snapshot.data!.docs;

          return ListView.builder(
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final complaint = complaints[index];
              final address =
                  complaint['address'] as String? ?? 'No address available';

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text('Complaint ID: ${complaint.id}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: ${complaint['name']}'),
                      Text('Status: ${complaint['status']}'),
                      const SizedBox(height: 4),
                      Text('Address: $address'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
