import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:Wow/services/referral_service.dart';
import 'package:Wow/pages/login_page/api/check_user_exist_api.dart';
import 'package:Wow/ui/loading_ui.dart';
import 'package:Wow/pages/splash_screen_page/api/fetch_login_user_profile_api.dart';
import 'package:Wow/pages/splash_screen_page/model/fetch_login_user_profile_model.dart';
import 'package:Wow/routes/app_routes.dart';
import 'package:Wow/pages/login_page/api/login_api.dart';
import 'package:Wow/pages/login_page/model/login_model.dart';
import 'package:Wow/utils/database.dart';
import 'package:Wow/utils/enums.dart';
import 'package:Wow/utils/internet_connection.dart';
import 'package:Wow/utils/utils.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart' as authFire;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
class LoginController extends GetxController {
  LoginModel? loginModel;
  FetchLoginUserProfileModel? fetchLoginUserProfileModel;

  List<String> randomNames = [
    "Emily Johnson",
    "Liam Smith",
    "Isabella Martinez",
    "Noah Brown",
    "Sofia Davis",
    "Oliver Wilson",
    "Mia Anderson",
    "James Thomas",
    "Ava Robinson",
    "Benjamin Lee",
    "Charlotte Miller",
    "Lucas Garcia",
    "Amelia White",
    "Ethan Harris",
    "Harper Clark",
    "Alexander Lewis",
    "Evelyn Walker",
    "Daniel Hall",
    "Grace Young",
    "Michael Allen",
  ];

  String onGetRandomName() {
    math.Random random = new math.Random();
    int index = random.nextInt(randomNames.length);
    return randomNames[index];
  }

  Future<void> onQuickLogin() async {
    if (InternetConnection.isConnect.value) {
      Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...

      // Calling Sign Up Api...

      final isLogin = await CheckUserExistApi.callApi(identity: Database.identity) ?? false;

      Utils.showLog("Quick Login User Is Exist => ${isLogin}");

      loginModel = isLogin
          ? await LoginApi.callApi(
              loginType: 3,
              email: Database.identity,
              identity: Database.identity,
              fcmToken: Database.fcmToken,
            )
          : await LoginApi.callApi(
              loginType: 3,
              email: Database.identity,
              identity: Database.identity,
              fcmToken: Database.fcmToken,
              userName: onGetRandomName(),
            );

      Get.back(); // Stop Loading...

      if (loginModel?.status == true && loginModel?.user?.id != null) {
        await onGetProfile(loginUserId: loginModel!.user!.id!); // Get Profile Api...
      } else if (loginModel?.message == "You are blocked by the admin.") {
        Utils.showToast("${loginModel?.message}");
        Utils.showLog("User Blocked By Admin !!");
      } else {
        Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
        Utils.showLog("Login Api Calling Failed !!");
      }
    } else {
      Utils.showToast(EnumLocal.txtConnectionLost.name.tr);
      Utils.showLog("Internet Connection Lost !!");
    }
  }

  Future<void> onGoogleLogin() async {

    if (InternetConnection.isConnect.value) {
      Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...

      final GoogleSignIn signIn = GoogleSignIn.instance;

      if (kDebugMode) print('Google Sign-In start');

      try {
        await signIn.initialize();

        signIn.authenticationEvents.listen((event) async {
          if (event is GoogleSignInAuthenticationEventSignIn) {
            final user = event.user;
            final auth = await user.authentication;

            final OAuthCredential credential = GoogleAuthProvider.credential(
              idToken: auth.idToken,
            );

            final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

            final authFire.User? firebaseUser = userCredential.user;
              if (firebaseUser != null) {
              /*  final docRef = FirebaseFirestore.instance
                    .collection('users')
                    .doc(firebaseUser.uid);

                final doc = await docRef.get();

                if (!doc.exists) {
                  await docRef.set({
                    'name': firebaseUser.displayName ?? '',
                    'email': firebaseUser.email ?? '',
                    'photoUrl': firebaseUser.photoURL ?? '',
                    'provider': 'google',
                  });
                }*/

                debugPrint('✅ Google Login successful');

                loginModel = await LoginApi.callApi(
                  loginType: 2,
                  email: userCredential?.user?.email ?? "",
                  identity: Database.identity,
                  fcmToken: Database.fcmToken,
                  userName: userCredential?.user?.displayName ?? "",
                );
                print("lllllllllllllllllllllllll Model: ${loginModel!.message.toString()}");
                Get.back(); // Stop Loading...

                if (loginModel?.status == true && loginModel?.user?.id != null) {
                  await onGetProfile(loginUserId: loginModel!.user!.id!); // Get Profile Api...
                }
                else if (loginModel?.message == "You are blocked by the admin.") {
                  Utils.showToast("${loginModel?.message}");
                  Utils.showLog("User Blocked By Admin !!");
                } else {
                  Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
                  Utils.showLog("Login Api Calling Failed !!");
                }
              }
          }
        });
        // Only call authenticate if supported
        if (signIn.supportsAuthenticate()) {
          await signIn.authenticate();
        } else {
          Utils.showToast('An unexpected error occurred.');
        }
        // Clean up the listener
    //    await subscription.cancel();
      } on FirebaseAuthException catch (e) {

        final errorMessage = switch (e.code) {
          'account-exists-with-different-credential' =>
          'Account exists with different credentials.',
          'invalid-credential' => 'Invalid credentials.',
          'user-disabled' => 'User account has been disabled.',
          'user-not-found' => 'No user found with these credentials.',
          'wrong-password' => 'Wrong password.',
          _ => 'An error occurred during Google Sign-In.'
        };

        Utils.showToast('An unexpected error occurred. $e',);
      } catch (e) {

        Utils.showToast('An unexpected error occurred. $e',);
        debugPrint('❗ Google Sign-In error: $e');
      }

    } else {
      Utils.showToast(EnumLocal.txtConnectionLost.name.tr);
      Utils.showLog("Internet Connection Lost !!");
    }
  }


  Future<void> onGetProfile({required String loginUserId}) async {
    Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...
    fetchLoginUserProfileModel = await FetchLoginUserProfileApi.callApi(loginUserId: loginUserId);
    Get.back(); // Stop Loading...

    if (fetchLoginUserProfileModel?.user?.id != null && fetchLoginUserProfileModel?.user?.loginType != null) {
      Database.onSetIsNewUser(false);
      Database.onSetLoginType(int.parse((fetchLoginUserProfileModel?.user?.loginType ?? 0).toString()));
      Database.fetchLoginUserProfileModel = fetchLoginUserProfileModel;
      Database.onSetLoginUserId(fetchLoginUserProfileModel!.user!.id!);

      // Auto-redeem pending referral if present
      try {
        final pending = Database.pendingReferralCode;
        if (pending.isNotEmpty) {
          final ok = await ReferralService.instance.redeemCode(
            referredUserId: fetchLoginUserProfileModel!.user!.id!,
            code: pending,
          );
          Utils.showLog("Referral auto-redeem: $ok");
          await Database.clearPendingReferralCode();
        }
      } catch (e) {
        Utils.showLog("Referral auto-redeem error: $e");
      }

    /*  if (fetchLoginUserProfileModel?.user?.country == "" || fetchLoginUserProfileModel?.user?.bio == "") {
        Get.toNamed(AppRoutes.fillProfilePage);
      } else {*/
        Get.offAllNamed(AppRoutes.bottomBarPage);
    //  }
    } else {
      Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
      Utils.showLog("Get Profile Api Calling Failed !!");
    }
  }

  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final signIn = GoogleSignIn.instance;

      // Optional: Provide your client ID (required for web or custom flow)
      await signIn.initialize(); // or with parameters like clientId, serverClientId

      // Check if sign-in is supported and initiate sign-in
      if (!signIn.supportsAuthenticate()) {
        print("GoogleSignIn.authenticate() is not supported on this platform.");
        return null;
      }

      // Perform authentication
      final GoogleSignInAccount auth =
      await signIn.authenticate();

      if (auth == null) {
        print("User cancelled the sign-in flow.");
        return null;
      }

      // Get accessToken and idToken
      final accessToken = auth.authentication.idToken;
      final idToken = auth.id;

      // Firebase sign-in
      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      print("Google Sign-In successful: ${userCredential.user?.email}");
      return userCredential;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }
  loginWithApple() async {
    try {
      Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      var auth = await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      final user = auth.user;
      log("oauthCredential :: $oauthCredential");
      log("user :: $user");
      if (user != null) {
        ///=====CALL API======///
        loginModel = await LoginApi.callApi(
          loginType: 4,
          email: user.email ?? ' ',
          identity: Database.identity,
          fcmToken: Database.fcmToken,
          userName: user.displayName ?? "",
        );

        Get.back(); // Stop Loading...

        if (loginModel?.status == true && loginModel?.user?.id != null) {
          await onGetProfile(loginUserId: loginModel!.user!.id!); // Get Profile Api...
        } else if (loginModel?.message == "You are blocked by the admin.") {
          Utils.showToast("${loginModel?.message}");
          Utils.showLog("User Blocked By Admin !!");
        } else {
          Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
          Utils.showLog("Login Api Calling Failed !!");
        }
      } else {
        Get.back(); // Stop Loading...
      }
    } catch (e) {
      Get.back(); // Stop Loading...
      Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
      log(" $e");
    }
  }
}
