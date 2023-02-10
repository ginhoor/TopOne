import 'package:top_one/app/logger.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> launchInBrowser(String url) async {
  var uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    logError("Cannot Launch Url");
  }
}
