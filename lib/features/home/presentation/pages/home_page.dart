import 'package:flutter/material.dart';
import 'package:flutter_photo_booth/features/auth/data/datasource/auth_local_datasource.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/component/space.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/style/color/colors_app.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../history/pages/history_page.dart';
import '../../../photo_booth/presentation/pages/main_page.dart';
import '../../../setting/presentation/pages/setting_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> saveLastOpenTime() async {
    final secureStorage = FlutterSecureStorage();
    final currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    await secureStorage.write(key: "last_open_time", value: currentTime);
  }

  Future<void> checkLicense() async {
    final secureStorage = FlutterSecureStorage();
    final expiredString = await secureStorage.read(key: "expired_at");
    final lastOpenTimeString = await secureStorage.read(key: "last_open_time");

    if (expiredString == null) {
      return;
    }

    final expiredAt = int.parse(expiredString);
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastOpenTime = int.tryParse(lastOpenTimeString ?? "");

    debugPrint(
      'DateTime Expired At: ${DateTime.fromMillisecondsSinceEpoch(expiredAt)}',
    );
    debugPrint('DateTime Now: ${DateTime.fromMillisecondsSinceEpoch(now)}');
    debugPrint(
      "Last Open Time: ${DateTime.fromMillisecondsSinceEpoch(lastOpenTime ?? 0)}",
    );

    if (now < (lastOpenTime ?? 0)) {
      debugPrint("System time has been changed to the past.");
      await AuthLocalDatasource().deleteExpiredAt();
      if (mounted) {
        context.showAlertError(
          message:
              "Sistem mendeteksi perubahan waktu ke masa lalu. Harap kembalikan waktu ke yang sebenarnya.",
        );
        context.pushReplacement(const LoginPage());
      }
    } else if (now > expiredAt) {
      debugPrint("License has expired.");
      await AuthLocalDatasource().deleteExpiredAt();
      if (mounted) {
        context.showAlertError(
          message: "License has expired. Please login again.",
        );
        context.pushReplacement(const LoginPage());
        saveLastOpenTime();
      }
    } else {
      debugPrint("License is still valid.");
      saveLastOpenTime();
    }
  }

  @override
  void initState() {
    super.initState();
    checkLicense();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Image.asset(
              'assets/images/Body.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),

            ListView(
              padding: EdgeInsets.all(16),
              children: [
                SpaceHeight(context.deviceHeight * 0.15),
                Image.asset('assets/images/title.png'),

                SpaceHeight(context.deviceHeight * 0.05),

                MenuCard(
                  title: "Camera",
                  subtitle: "Mulai sesi foto booth Anda",
                  icon: Icons.camera_alt,
                  onTap: () {
                    context.push(const MainPage());
                  },
                ),

                SpaceHeight(20),
                MenuCard(
                  title: "Setting",
                  subtitle: "Atur preferensi dan konfigurasi Anda",
                  icon: Icons.settings,
                  onTap: () {
                    context.push(const SettingPage());
                  },
                ),
                SpaceHeight(20),
                MenuCard(
                  title: 'History',
                  subtitle: 'Lihat riwayat aktivitas Anda',
                  icon: Icons.history,
                  onTap: () {
                    context.push(const HistoryPage());
                  },
                ),

                SpaceHeight(20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  const MenuCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ColorsApp.primary.withAlpha(204),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            SpaceWidth(8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios_outlined, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
