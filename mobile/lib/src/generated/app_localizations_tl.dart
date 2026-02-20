// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tagalog (`tl`).
class AppLocalizationsTl extends AppLocalizations {
  AppLocalizationsTl([String locale = 'tl']) : super(locale);

  @override
  String get appTitle => 'LIGTAS COMMAND';

  @override
  String get loginGateway => 'GATEWAY NG PAGPAPAHINTULOT';

  @override
  String get emailLabel => 'Email Address';

  @override
  String get emailHint => 'iyong.pangalan@cdrrmo.ph';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Ipasok ang secure na password';

  @override
  String get signInButton => 'MAG-SIGN IN';

  @override
  String get googleSignInButton => 'MAGPATULOY GAMIT ANG GOOGLE';

  @override
  String accessGranted(String name) {
    return 'Pinayagan ang Pag-access. Maligayang pagbabalik, $name!';
  }

  @override
  String get inventoryTitle => 'Imbentaryo';

  @override
  String get noInventoryFound => 'Walang nakitang gamit';

  @override
  String get noInventoryAvailable => 'Walang available na imbentaryo';

  @override
  String get categoryAll => 'Lahat';

  @override
  String get categoryRescue => 'Rescue';

  @override
  String get categoryMedical => 'Medikal';

  @override
  String get categoryComms => 'Komunikasyon';

  @override
  String get categoryVehicles => 'Sasakyan';

  @override
  String get categoryTools => 'Kasangkapan';

  @override
  String get categoryPPE => 'PPE';

  @override
  String get categoryLogistics => 'Logistics';

  @override
  String get categoryOffice => 'Opisina';
}
