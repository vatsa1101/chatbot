import 'package:auto_size_text/auto_size_text.dart';
import 'package:chatbot/auth_controller.dart';
import 'package:chatbot/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController _authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(
        () => Container(
          height: Get.height,
          width: Get.width,
          decoration: BoxDecoration(
            color: AppColors.bgGray,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Center(
                  child: Hero(
                    tag: 'logo',
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: Get.width * 0.7,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 30,
                ),
                child: InkWell(
                  onTap: () async {
                    await _authController.signInwithGoogle();
                  },
                  child: Container(
                    width: Get.width * 0.8,
                    decoration: BoxDecoration(
                      color: AppColors.fgGray,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                        top: 10,
                        bottom: 10,
                      ),
                      child: _authController.isLoading.value
                          ? Center(
                              child: Container(
                                height: 30,
                                child: FittedBox(
                                  fit: BoxFit.fitHeight,
                                  child: CircularProgressIndicator(
                                    color: AppColors.blueColor,
                                  ),
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/google.png',
                                  height: 30,
                                  fit: BoxFit.fitHeight,
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Flexible(
                                  child: AutoSizeText(
                                    'Sign In with Google',
                                    minFontSize: 1,
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: AppColors.blueColor,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
