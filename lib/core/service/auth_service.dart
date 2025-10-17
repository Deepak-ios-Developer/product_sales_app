import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../common_widgets/app_loader.dart';
import '../routes/app_routes.dart';
import '../storage/storage.dart'; // Import your Product List screen

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
            builder: (context) =>  AppLoader(label: '',indicatorSize: 20.sp),);



      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        Navigator.pop(context); // Close loader if user cancels
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;
      if (user != null) {
        // ✅ Save user details in local storage
        await StorageService.saveUserData(
          userId: user.uid,
          userName: user.displayName ?? '',
          userEmail: user.email ?? '',
          userPhoto: user.photoURL ?? '',
        );
        debugPrint('User saved to storage');
      }

      notifyListeners();

      Navigator.pop(context); // Close the loader
      Navigator.pushReplacementNamed(context, AppRoutes.products); // Navigate to product list screen
    } catch (e) {
      Navigator.pop(context); // Close loader if any error
      debugPrint('Google Sign-In error: $e');
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    notifyListeners();
  }
}
