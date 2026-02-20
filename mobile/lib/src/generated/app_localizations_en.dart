// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'LIGTAS COMMAND';

  @override
  String get loginGateway => 'AUTHORIZATION GATEWAY';

  @override
  String get emailLabel => 'Email Address';

  @override
  String get emailHint => 'your.name@cdrrmo.ph';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Enter secure password';

  @override
  String get signInButton => 'SIGN IN';

  @override
  String get googleSignInButton => 'CONTINUE WITH GOOGLE';

  @override
  String accessGranted(String name) {
    return 'Access Granted. Welcome back, $name!';
  }

  @override
  String get inventoryTitle => 'Inventory';

  @override
  String get noInventoryFound => 'No items found';

  @override
  String get noInventoryAvailable => 'No inventory available';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryRescue => 'Rescue';

  @override
  String get categoryMedical => 'Medical';

  @override
  String get categoryComms => 'Comms';

  @override
  String get categoryVehicles => 'Vehicles';

  @override
  String get categoryTools => 'Tools';

  @override
  String get categoryPPE => 'PPE';

  @override
  String get categoryLogistics => 'Logistics';

  @override
  String get categoryOffice => 'Office';
}
