import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Wow/main.dart';
import 'package:Wow/pages/login_page/controller/login_controller.dart';
import 'package:Wow/routes/app_routes.dart';
import 'package:Wow/utils/asset.dart';
import 'package:Wow/utils/color.dart';
import 'package:Wow/utils/constant.dart';
import 'package:Wow/utils/enums.dart';
import 'package:Wow/utils/font_style.dart';

class LoginView extends GetView<LoginController> {
  LoginView({super.key});

  // Observable variable to track terms agreement
  final RxBool isTermsAccepted = false.obs;

  // URLs for terms and privacy policy
  final String termsOfServiceUrl = "https://NexNex.site/terms";
  final String privacyPolicyUrl = "https://NexNex.site/privacy";

  @override
  Widget build(BuildContext context) {
    Future.delayed(
      Duration(milliseconds: 300),
          () => SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: AppColor.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
    );
    return Scaffold(
      body: Stack(
        children: [
          Container(
              height: 500,
              child: Image.asset(AppAsset.imgLoginBg, height: Get.height, width: Get.width, fit: BoxFit.fill)
          ),
          Positioned(
            bottom: 0,
            child: Container(
              height: 600,
              width: Get.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColor.transparent, AppColor.black, AppColor.black, AppColor.black],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SizedBox(
            height: Get.height,
            width: Get.width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  25.height,
                  SizedBox(
                    width: Get.width / 1.2,
                    child: Text(
                      EnumLocal.txtLoginTitle.name.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 33,
                        color: AppColor.white,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w900,
                        fontFamily: AppConstant.appFontBold,
                      ),
                    ),
                  ),
                  5.height,
                  Text(
                    EnumLocal.txtLoginSubTitle.name.tr,
                    textAlign: TextAlign.center,
                    style: AppFontStyle.styleW400(AppColor.white, 14),
                  ),
                  20.height,

                  // Terms and Conditions Agreement Section
                  // Container(
                  //   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  //   decoration: BoxDecoration(
                  //     color: AppColor.white.withOpacity(0.1),
                  //     borderRadius: BorderRadius.circular(12),
                  //     border: Border.all(
                  //       color: AppColor.white.withOpacity(0.2),
                  //       width: 1,
                  //     ),
                  //   ),
                  //   child: Obx(() => Row(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       GestureDetector(
                  //         onTap: () {
                  //           isTermsAccepted.value = !isTermsAccepted.value;
                  //         },
                  //         child: Container(
                  //           width: 20,
                  //           height: 20,
                  //           margin: EdgeInsets.only(top: 2),
                  //           decoration: BoxDecoration(
                  //             color: isTermsAccepted.value ? AppColor.white : Colors.transparent,
                  //             border: Border.all(
                  //               color: AppColor.white,
                  //               width: 2,
                  //             ),
                  //             borderRadius: BorderRadius.circular(4),
                  //           ),
                  //           child: isTermsAccepted.value
                  //               ? Icon(
                  //             Icons.check,
                  //             size: 14,
                  //             color: AppColor.black,
                  //           )
                  //               : null,
                  //         ),
                  //       ),
                  //       10.width,
                  //       Expanded(
                  //         child: RichText(
                  //           text: TextSpan(
                  //             style: AppFontStyle.styleW400(AppColor.white, 13),
                  //             children: [
                  //               TextSpan(text: "By logging in, you agree to our "),
                  //               WidgetSpan(
                  //                 child: GestureDetector(
                  //                   onTap: () => _launchUrl(termsOfServiceUrl),
                  //                   child: Text(
                  //                     "Terms of Service",
                  //                     style: AppFontStyle.styleW600(AppColor.white, 13).copyWith(
                  //                       decoration: TextDecoration.underline,
                  //                       decorationColor: AppColor.white,
                  //                     ),
                  //                   ),
                  //                 ),
                  //               ),
                  //               TextSpan(text: " and "),
                  //               WidgetSpan(
                  //                 child: GestureDetector(
                  //                   onTap: () => _launchUrl(privacyPolicyUrl),
                  //                   child: Text(
                  //                     "Privacy Policy",
                  //                     style: AppFontStyle.styleW600(AppColor.white, 13).copyWith(
                  //                       decoration: TextDecoration.underline,
                  //                       decorationColor: AppColor.white,
                  //                     ),
                  //                   ),
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   )),
                  // ),
                  30.height,

                  // Quick Login Button
                  Obx(() => GestureDetector(
                    onTap: isTermsAccepted.value ? controller.onQuickLogin : _showTermsAlert,
                    child: Container(
                      height: 56,
                      width: Get.width,
                      padding: EdgeInsets.only(left: 6, right: 52),
                      decoration: BoxDecoration(
                        gradient: isTermsAccepted.value
                            ? AppColor.primaryLinearGradient
                            : LinearGradient(
                          colors: [AppColor.white.withOpacity(0.3), AppColor.white.withOpacity(0.3)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 46,
                            width: 46,
                            decoration: BoxDecoration(
                              color: isTermsAccepted.value ? AppColor.white : AppColor.white.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                                child: Image.asset(
                                  AppAsset.icQuickLogo,
                                  width: 24,
                                  color: isTermsAccepted.value ? null : AppColor.black.withOpacity(0.5),
                                )
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                EnumLocal.txtQuickLogIn.name.tr,
                                style: AppFontStyle.styleW600(
                                    isTermsAccepted.value ? AppColor.white : AppColor.white.withOpacity(0.6),
                                    16
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
                  20.height,
                  Row(
                    children: [
                      Expanded(child: Divider(color: AppColor.white.withOpacity(0.15))),
                      15.width,
                      Text(
                        EnumLocal.txtOr.name.tr,
                        style: AppFontStyle.styleW600(AppColor.white, 12),
                      ),
                      15.width,
                      Expanded(child: Divider(color: AppColor.white.withOpacity(0.15))),
                    ],
                  ),
                  15.height,
                  Platform.isIOS
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Obx(() => GestureDetector(
                        onTap: isTermsAccepted.value ? controller.onGoogleLogin : _showTermsAlert,
                        child: Container(
                          height: 52,
                          width: 52,
                          decoration: BoxDecoration(
                            color: isTermsAccepted.value ? AppColor.white : AppColor.white.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                              child: Image.asset(
                                AppAsset.icGoogleLogo,
                                width: 32,
                                color: isTermsAccepted.value ? null : AppColor.black.withOpacity(0.5),
                              )
                          ),
                        ),
                      )),
                    ],
                  )
                      : Row(
                    children: [
                      Expanded(
                        child: Obx(() => GestureDetector(
                          onTap: isTermsAccepted.value ? controller.onGoogleLogin : _showTermsAlert,
                          child: Container(
                            height: 56,
                            padding: EdgeInsets.only(left: 6, right: 52),
                            decoration: BoxDecoration(
                              color: isTermsAccepted.value
                                  ? AppColor.colorDarkPink
                                  : AppColor.colorDarkPink.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: 46,
                                  width: 46,
                                  decoration: BoxDecoration(
                                    color: isTermsAccepted.value ? AppColor.white : AppColor.white.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                      child: Image.asset(
                                        AppAsset.icGoogleLogo,
                                        width: 32,
                                        color: isTermsAccepted.value ? null : AppColor.black.withOpacity(0.5),
                                      )
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  EnumLocal.txtGoogle.name.tr,
                                  style: AppFontStyle.styleW600(
                                      isTermsAccepted.value ? AppColor.white : AppColor.white.withOpacity(0.6),
                                      16
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                      ),
                    ],
                  ),
                  15.height,

                  // Terms and Conditions Agreement Section (at bottom)
                  Obx(() => GestureDetector(
                    onTap: () {
                      isTermsAccepted.value = !isTermsAccepted.value;
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: isTermsAccepted.value ? Colors.blue : Colors.transparent,
                            border: Border.all(
                              color: AppColor.white.withOpacity(0.7),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: isTermsAccepted.value
                              ? Icon(
                            Icons.check,
                            size: 12,
                            color: AppColor.white,
                          )
                              : null,
                        ),
                        9.width,
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: AppFontStyle.styleW400(AppColor.white.withOpacity(0.8), 12),
                              children: [
                                TextSpan(text: "By logging in, you agree to our "),
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () => _launchUrl(termsOfServiceUrl),
                                    child: Text(
                                      "Terms of Service",
                                      style: AppFontStyle.styleW500(Colors.lightBlue, 12).copyWith(
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.lightBlue,
                                      ),
                                    ),
                                  ),
                                ),
                                TextSpan(text: " and "),
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () => _launchUrl(privacyPolicyUrl),
                                    child: Text(
                                      "Privacy Policy",
                                      style: AppFontStyle.styleW500(Colors.lightBlue, 12).copyWith(
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.lightBlue,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                  10.height,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method to launch URLs
  void _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        "Error",
        "Could not launch $url",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Method to show alert when terms are not accepted
  void _showTermsAlert() {
    Get.snackbar(
      "Terms Required",
      "Please accept the Terms of Service and Privacy Policy to continue",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColor.colorDarkPink,
      colorText: AppColor.white,
      duration: Duration(seconds: 3),
    );
  }
}