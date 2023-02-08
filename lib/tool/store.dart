import 'package:in_app_review/in_app_review.dart';
import 'package:top_one/tool/shared_preferences_helper.dart';
import 'package:top_one/tool/time.dart';

final InAppReview inAppReview = InAppReview.instance;

void showRateView() async {
  const key = SharedPreferenceKeys.latest_rate_date;
  if (SharedPreferencesHelper().getInt(key) != null) return;
  if (await inAppReview.isAvailable()) {
    inAppReview.requestReview();
    SharedPreferencesHelper().setInt(key, currentMilliseconds());
  }
}

void openStorePage() async {
  final InAppReview inAppReview = InAppReview.instance;
  var appStoreId = "";
  var microsoftStoreId = "";
  inAppReview.openStoreListing(
      appStoreId: appStoreId, microsoftStoreId: microsoftStoreId);
}
