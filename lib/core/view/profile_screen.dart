import 'package:flutter/material.dart';
import 'package:product_sale_app/core/routes/app_routes.dart';
import 'package:product_sale_app/core/service/auth_service.dart';
import 'package:product_sale_app/core/themes/app_fonts.dart';
import 'package:product_sale_app/core/themes/app_theme.dart';
import 'package:provider/provider.dart';
import '../common_widgets/common_button.dart';
import '../constants/common_strings.dart';
import '../storage/storage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = 'User';
  String userEmail = 'user@example.com';
  String userPhoto = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await StorageService.getUserData();
    setState(() {
      userName = userData['userName'] ?? 'User';
      userEmail = userData['userEmail'] ?? 'user@example.com';
      userPhoto = userData['userPhoto'] ?? '';
    });
  }

  Future<void> _logout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.signOut();
    await StorageService.clearUserData();
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final placeholderImage = 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png';

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(userPhoto.isNotEmpty ? userPhoto : placeholderImage),
            ),
            const SizedBox(height: 20),
            Text(
              userName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: AppFontWeight.semibold.value,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              userEmail,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.placeHolderColour.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 40),
            CommonButton(
              text: AppStrings.logout,
              backgroundColor: AppTheme.black,
              textColor: AppTheme.white,
              onPressed: _logout,
            ),
            const Spacer(),
            Column(
              children: [
                Icon(
                  Icons.phone_iphone,
                  size: 40,
                  color: Theme.of(context).primaryColorLight,
                ),
                const SizedBox(height: 8),
                Text(
                 AppStrings.iPhoneSaleApp,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.placeHolderColour.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
