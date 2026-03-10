import 'package:flutter/material.dart';
import 'package:flutter_photo_booth/core/extensions/build_context_ext.dart';

import '../../../home/presentation/pages/home_page.dart';
import '../../data/datasource/auth_local_datasource.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    loadingScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: AuthLocalDatasource().hasValidToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loadingScreen();
          }
          if (snapshot.hasData && snapshot.data == true) {
            Future.delayed(const Duration(seconds: 2), () {
              if (context.mounted) {
                context.pushReplacement(const HomePage());
              }
            });
          } else {
            Future.delayed(const Duration(seconds: 2), () {
              if (context.mounted) {
                context.pushReplacement(const LoginPage());
              }
            });
          }
          return loadingScreen();
        },
      ),
    );
  }

  Widget loadingScreen() {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          Image.asset(
            'assets/images/Body.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Center(child: Image.asset('assets/images/title.png', width: 400)),
        ],
      ),
    );
  }
}
