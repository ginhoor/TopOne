import 'package:in_app_review/in_app_review.dart';

final InAppReview inAppReview = InAppReview.instance;

void showRateView() async {
  if (await inAppReview.isAvailable()) {
    inAppReview.requestReview();
  }
}

void openStorePage() async {
  final InAppReview inAppReview = InAppReview.instance;
  var appStoreId = "";
  var microsoftStoreId = "";
  inAppReview.openStoreListing(
      appStoreId: appStoreId, microsoftStoreId: microsoftStoreId);
}
