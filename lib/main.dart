import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:product_sale_app/core/model/product_model.dart';
import 'package:product_sale_app/core/view/product_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/routes/app_routes.dart';
import 'core/themes/app_theme.dart';
import 'core/themes/theme_provider.dart';
import 'core/view/splash_screen.dart'; // <-- import splash screen
import 'core/service/auth_service.dart'; // <-- import AuthService

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey:
          "AIzaSyDJp2FC_yIyEfIULO_dICLBC2ebcMF4E4U", // From api_key > current_key
      appId:
          "1:751846036862:android:2c887e1c7f3f18985ecf2f", // From client_info > mobilesdk_app_id
      messagingSenderId: "751846036862", // From project_info > project_number
      projectId: "friendlychat-6234b", // From project_info > project_id
      storageBucket: "friendlychat-6234b.appspot.com", // Optional (bonus)
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
                create: (_) => ThemeProvider()), // ThemeProvider
            ChangeNotifierProvider(
                create: (_) => AuthService()), // AuthService provider
          ],
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return MaterialApp(
                title: 'Products App',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeProvider.themeMode,
                home: const SplashScreen(),
                routes: AppRoutes.routes,
                onGenerateRoute: AppRoutes.generateRoute,
              );
            },
          ),
        );
      },
    );
  }
}
