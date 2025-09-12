import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:Wow/utils/database.dart';
import 'package:Wow/utils/utils.dart';

class SubscriptionController extends GetxController {
  final InAppPurchase iap = InAppPurchase.instance;
  final RxBool isAvailable = false.obs;
  final RxBool isProcessing = false.obs;
  final String productId = 'wow_premium_sub_1';

  @override
  void onInit() {
    super.onInit();
    _initStoreInfo();
  }

  Future<void> _initStoreInfo() async {
    final available = await iap.isAvailable();
    isAvailable.value = available;
  }

  Future<void> purchase() async {
    if (!isAvailable.value) {
      Utils.showToast('Store not available');
      return;
    }
    isProcessing.value = true;
    try {
      final response = await iap.queryProductDetails({productId});
      if (response.productDetails.isEmpty) {
        Utils.showToast('Product not found');
        isProcessing.value = false;
        return;
      }
      final purchaseParam = PurchaseParam(productDetails: response.productDetails.first);
      await iap.buyNonConsumable(purchaseParam: purchaseParam);
      // For demo: mark as verified locally
      Database.fetchLoginUserProfileModel?.user?.isVerified = true;
      Utils.showToast('Subscribed! Verified badge enabled');
    } catch (e) {
      Utils.showToast('Purchase failed');
    } finally {
      isProcessing.value = false;
    }
  }
}


