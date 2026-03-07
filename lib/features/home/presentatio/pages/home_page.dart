import 'package:flutter/material.dart';
import '../../../../core/component/space.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../photo_booth/presentation/pages/main_page.dart';
import '../../../setting/presentatio/pages/setting_page.dart';

import '../../../../core/component/buttons.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Container(
            height: 200,
            color: Colors.blue,
            child: const Center(
              child: Text(
                'Welcome to the Home Page',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
          SpaceHeight(20),
          Button.filled(
            onPressed: () {
              context.push(MainPage());
            },
            label: 'Camera',
            color: Colors.blue,
          ),
          SpaceHeight(20),
          Button.filled(
            onPressed: () {
              context.push(SettingPage());
            },
            label: 'Settings',
            color: Colors.green,
          ),
          SpaceHeight(20),
          Button.filled(
            onPressed: () {},
            label: 'History',
            color: Colors.purple,
          ),
        ],
      ),
    );
  }
}
