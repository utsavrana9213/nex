import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:Wow/utils/utils.dart';

class AdMobService {
  AdMobService._();
  static final AdMobService instance = AdMobService._();

  static const String _adUnitId = 'ca-app-pub-3940256099942544/1033173712';
  
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  int _adCounter = 0;
  static const int _adFrequency = 3; // Show ad every 3 scrolls

  Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      Utils.showLog('AdMob initialized');
    } catch (e) {
      Utils.showLog('AdMob initialization error: $e');
    }
  }

  void loadInterstitialAd() {
    if (_isAdLoaded) return;

    InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          Utils.showLog('Interstitial ad loaded');
          _interstitialAd = ad;
          _isAdLoaded = true;
          _setupAdCallbacks();
        },
        onAdFailedToLoad: (LoadAdError error) {
          Utils.showLog('Interstitial ad failed to load: $error');
          _isAdLoaded = false;
        },
      ),
    );
  }

  void _setupAdCallbacks() {
    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        Utils.showLog('Ad showed full screen content');
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        Utils.showLog('Ad failed to show full screen content: $err');
        ad.dispose();
        _isAdLoaded = false;
      },
      onAdDismissedFullScreenContent: (ad) {
        Utils.showLog('Ad was dismissed');
        ad.dispose();
        _isAdLoaded = false;
        // Load next ad
        loadInterstitialAd();
      },
      onAdImpression: (ad) {
        Utils.showLog('Ad recorded an impression');
      },
      onAdClicked: (ad) {
        Utils.showLog('Ad was clicked');
      },
    );
  }

  void onReelScrolled() {
    _adCounter++;
    if (_adCounter >= _adFrequency && _isAdLoaded) {
      showInterstitialAd();
      _adCounter = 0;
    }
  }

  void showInterstitialAd() {
    if (_interstitialAd != null && _isAdLoaded) {
      _interstitialAd!.show();
    } else {
      Utils.showLog('No ad available to show');
      loadInterstitialAd();
    }
  }

  void dispose() {
    _interstitialAd?.dispose();
    _isAdLoaded = false;
  }
}
