import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:signa_video_to_text/features/config/routes/app_pages.dart';
import 'package:signa_video_to_text/features/config/routes/route_names.dart';
import 'package:signa_video_to_text/features/config/themes/colors_theme.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 980),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'SIGNA: Sign Language Translator Assistant',
          theme: ThemeData(
            fontFamily: "Poppins",
            scaffoldBackgroundColor: WarnaApp.wrBody,
          ),
          darkTheme: ThemeData(
            fontFamily: "Poppins",
            scaffoldBackgroundColor: WarnaApp.wrBody,
          ),
          debugShowCheckedModeBanner: false,
          initialRoute: RouteNames.splashscreen,
          getPages: AppPages.pages,
        );
      },
    );
  }
}
