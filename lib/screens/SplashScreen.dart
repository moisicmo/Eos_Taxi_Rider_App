import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/Extensions/StringExtensions.dart';
import '../main.dart';
import '../../screens/WalkThroughtScreen.dart';
import '../../utils/Colors.dart';
import '../../utils/Constants.dart';
import '../../utils/Extensions/app_common.dart';
import '../network/RestApis.dart';
import '../utils/images.dart';
import 'EditProfileScreen.dart';
import 'SignInScreen.dart';
import 'DashBoardScreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    versioncontrol();
    init();
  }

  void versioncontrol() {
    DatabaseReference versionRef = FirebaseDatabase.instance
        .ref("settings/users_app_version");
    versionRef.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.value != users_app_version) {
        // Belirli bir şart sağlandığında iki seçenekli bir uyarı mesajı göster
        showDialog(
          context: context,
          barrierDismissible: false, // Dialogun dışına tıklanıldığında kapatılmaması için
          builder: (BuildContext context) {
            return WillPopScope(
                onWillPop: () async => false, // Geri tuşu işlevselliğini devre dışı bırak
            child: AlertDialog(
              title: Text(language.theapplicationisnotuptodate),
              content: Text(language.theapplicationisnotcurrent),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    // İlk seçenek: Linke git
                    launch('https://play.google.com/store/apps/details?id=com.eostaxi.users_app');
                    if(Platform.isAndroid) {
                      versioncontrol();
                      SystemNavigator.pop();
                    } else if (Platform.isIOS) {
                      versioncontrol();
                      exit(0);
                    } else {
                      versioncontrol();
                      SystemNavigator.pop();
                    }
                  },
                  child: Text(language.updateapp),
                ),
                ElevatedButton(
                  onPressed: () {
                    versioncontrol();
                    exit(0);
                  },
                  child: Text(language.cancelapp),
                ),
              ],
            )
            );
          },
        );
      }
    });
  }

  void init() async {
    versioncontrol();
    await Future.delayed(Duration(seconds: 2));
    if (sharedPref.getBool(IS_FIRST_TIME) ?? true) {
      versioncontrol();
      await Geolocator.requestPermission().then((value) async {
        await Geolocator.getCurrentPosition().then((value) {
          sharedPref.setDouble(LATITUDE, value.latitude);
          sharedPref.setDouble(LONGITUDE, value.longitude);
          sharedPref.setBool(IS_FIRST_TIME, false);
          launchScreen(context, SignInScreen(), isNewTask: true);

        });
      });
    } else {
      if (!appStore.isLoggedIn) {
        versioncontrol();
        launchScreen(context, SignInScreen(), pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
      } else {
        versioncontrol();
        if (sharedPref.getString(CONTACT_NUMBER).validate().isEmptyOrNull) {
          versioncontrol();
          launchScreen(context, EditProfileScreen(isGoogle: true), isNewTask: true, pageRouteAnimation: PageRouteAnimation.Slide);
        } else {
          versioncontrol();
          launchScreen(context, DashBoardScreen(), pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
        }
      }
      versioncontrol();
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(ic_app_logo, fit: BoxFit.contain, height: 150, width: 150),
            SizedBox(height: 16),
            Text(language.appName, style: boldTextStyle(color: Colors.white, size: 22)),
          ],
        ),
      ),
    );
  }
}
