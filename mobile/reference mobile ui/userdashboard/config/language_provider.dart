import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum SupportedLanguage {
  english,
  tagalog,
  cebuano,
}

class LanguageProvider extends ChangeNotifier {
  SupportedLanguage _currentLanguage = SupportedLanguage.english;

  SupportedLanguage get currentLanguage => _currentLanguage;

  void setLanguage(SupportedLanguage language) {
    _currentLanguage = language;
    notifyListeners();
  }

  String getLanguageName(SupportedLanguage language) {
    switch (language) {
      case SupportedLanguage.english:
        return 'English';
      case SupportedLanguage.tagalog:
        return 'Tagalog';
      case SupportedLanguage.cebuano:
        return 'Cebuano';
    }
  }

  String getLanguageNativeName(SupportedLanguage language) {
    switch (language) {
      case SupportedLanguage.english:
        return 'English';
      case SupportedLanguage.tagalog:
        return 'Filipino';
      case SupportedLanguage.cebuano:
        return 'Bisaya';
    }
  }

  String getLanguageCode(SupportedLanguage language) {
    switch (language) {
      case SupportedLanguage.english:
        return 'en';
      case SupportedLanguage.tagalog:
        return 'tl';
      case SupportedLanguage.cebuano:
        return 'ceb';
    }
  }
}

class AppLocalizations {
  final SupportedLanguage language;

  AppLocalizations(this.language);

  // Common UI Elements
  String get settings =>
      _getTranslation('settings', 'Mga Setting', 'Mga Setting');
  String get profile => _getTranslation('profile', 'Profile', 'Profile');
  String get languageText => _getTranslation('language', 'Wika', 'Pinulongan');
  String get theme => _getTranslation('theme', 'Tema', 'Tema');
  String get notifications =>
      _getTranslation('notifications', 'Mga Abiso', 'Mga Pahibalo');
  String get security => _getTranslation('security', 'Seguridad', 'Seguridad');
  String get about => _getTranslation('about', 'Tungkol', 'Mahitungod');
  String get logout => _getTranslation('logout', 'Mag-logout', 'Gawas');
  String get save => _getTranslation('save', 'I-save', 'I-save');
  String get cancel => _getTranslation('cancel', 'Kanselahin', 'Kanselahon');
  String get edit => _getTranslation('edit', 'I-edit', 'I-edit');
  String get delete => _getTranslation('delete', 'Tanggalin', 'Tangtangon');
  String get confirm =>
      _getTranslation('confirm', 'Kumpirmahin', 'Kumpirmahon');
  String get yes => _getTranslation('yes', 'Oo', 'Oo');
  String get no => _getTranslation('no', 'Hindi', 'Dili');
  String get ok => _getTranslation('ok', 'OK', 'OK');
  String get loading => _getTranslation('loading', 'Naglo-load', 'Nag-load');
  String get error => _getTranslation('error', 'Error', 'Sayop');
  String get success => _getTranslation('success', 'Tagumpay', 'Kalampusan');

  // Dashboard
  String get dashboard =>
      _getTranslation('dashboard', 'Dashboard', 'Dashboard');
  String get marineConditions => _getTranslation(
      'marineConditions', 'Mga Kondisyon sa Dagat', 'Mga Kahimtang sa Dagat');
  String get banPeriod =>
      _getTranslation('banPeriod', 'Panahon ng Ban', 'Panahon sa Ban');
  String get education =>
      _getTranslation('education', 'Edukasyon', 'Edukasyon');
  String get complaints =>
      _getTranslation('complaints', 'Mga Reklamo', 'Mga Reklamo');
  String get help => _getTranslation('help', 'Tulong', 'Tabang');

  // Marine Conditions
  String get temperature =>
      _getTranslation('temperature', 'Temperatura', 'Temperatura');
  String get windSpeed =>
      _getTranslation('windSpeed', 'Bilis ng Hangin', 'Kusog sa Hangin');
  String get uvIndex => _getTranslation('uvIndex', 'UV Index', 'UV Index');
  String get waveHeight =>
      _getTranslation('waveHeight', 'Taas ng Alon', 'Kataas sa Balud');
  String get safeForSailing => _getTranslation(
      'safeForSailing', 'Ligtas para sa Paglalayag', 'Luwas alang sa Paglawig');
  String get cautionAdvised =>
      _getTranslation('cautionAdvised', 'Mag-ingat', 'Mag-amping');
  String get notRecommended => _getTranslation(
      'notRecommended', 'Hindi Inirerekomenda', 'Dili Girekomenda');

  // Ban Period
  String get fishingBan =>
      _getTranslation('fishingBan', 'Ban sa Pangingisda', 'Ban sa Pangisda');
  String get startDate =>
      _getTranslation('startDate', 'Petsa ng Simula', 'Petsa sa Sugod');
  String get endDate =>
      _getTranslation('endDate', 'Petsa ng Katapusan', 'Petsa sa Katapusan');
  String get currentSchedule => _getTranslation(
      'currentSchedule', 'Kasalukuyang Iskedyul', 'Karon nga Iskedyul');

  // Education
  String get oceanEducation => _getTranslation(
      'oceanEducation', 'Edukasyon sa Karagatan', 'Edukasyon sa Kadagatan');
  String get marineLife =>
      _getTranslation('marineLife', 'Buhay sa Dagat', 'Kinabuhi sa Dagat');
  String get conservation =>
      _getTranslation('conservation', 'Konserbasyon', 'Konserbasyon');
  String get regulations =>
      _getTranslation('regulations', 'Mga Regulasyon', 'Mga Regulasyon');
  String get oceanTech => _getTranslation(
      'oceanTech', 'Teknolohiya sa Karagatan', 'Teknolohiya sa Kadagatan');

  // Complaints
  String get submitComplaint => _getTranslation(
      'submitComplaint', 'Magsumite ng Reklamo', 'Magsumite og Reklamo');
  String get complaintStatus => _getTranslation(
      'complaintStatus', 'Status ng Reklamo', 'Status sa Reklamo');
  String get pending => _getTranslation('pending', 'Naghihintay', 'Nagpaabot');
  String get inProgress => _getTranslation('inProgress', 'Ginagawa', 'Gibuhat');
  String get resolved => _getTranslation('resolved', 'Nalutas', 'Nahusay');

  // Settings
  String get profilePicture => _getTranslation(
      'profilePicture', 'Larawan ng Profile', 'Larawan sa Profile');
  String get displayName => _getTranslation(
      'displayName', 'Pangalan na Ipapakita', 'Ngalan nga Ipakita');
  String get email => _getTranslation('email', 'Email', 'Email');
  String get phoneNumber => _getTranslation(
      'phoneNumber', 'Numero ng Telepono', 'Numero sa Telepono');
  String get twoFactorAuth => _getTranslation('twoFactorAuth',
      'Dalawang-Factor na Authentication', 'Duhang-Factor nga Authentication');
  String get privacyPolicy => _getTranslation(
      'privacyPolicy', 'Patakaran sa Privacy', 'Patakaran sa Privacy');
  String get termsOfService => _getTranslation(
      'termsOfService', 'Mga Tuntunin ng Serbisyo', 'Mga Tuntunin sa Serbisyo');

  // Notifications
  String get marineConditionsUpdated => _getTranslation(
      'marineConditionsUpdated',
      'Na-update ang Mga Kondisyon sa Dagat',
      'Na-update ang Mga Kahimtang sa Dagat');
  String get newEducationContent => _getTranslation('newEducationContent',
      'Bagong Nilalaman sa Edukasyon', 'Bag-ong Sulud sa Edukasyon');
  String get complaintUpdate => _getTranslation(
      'complaintUpdate', 'Update ng Reklamo', 'Update sa Reklamo');

  // Help & Support
  String get faq => _getTranslation(
      'faq', 'Mga Madalas na Tanong', 'Mga Kasagarang Pangutana');
  String get contactSupport => _getTranslation(
      'contactSupport', 'Makipag-ugnayan sa Suporta', 'Makig-uban sa Suporta');
  String get chatbot => _getTranslation('chatbot', 'Chatbot', 'Chatbot');

  String _getTranslation(String english, String tagalog, String cebuano) {
    switch (language) {
      case SupportedLanguage.english:
        return english;
      case SupportedLanguage.tagalog:
        return tagalog;
      case SupportedLanguage.cebuano:
        return cebuano;
    }
  }
}

// Extension to easily access localizations
extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n {
    final languageProvider = Provider.of<LanguageProvider>(this, listen: false);
    return AppLocalizations(languageProvider.currentLanguage);
  }
}
