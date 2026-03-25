import 'package:flutter/material.dart';

import '../../../../core/component/space.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../token/presentation/pages/generate_token_page.dart';
import '../widgets/setting_menu_card.dart';
import 'countdown_setting_page.dart';
import 'custom_button_tema_page.dart';
import 'custom_tema_page.dart';
import 'frame_template_list_page.dart';
import 'generate_voucher_page.dart';
import 'setting_printer_page.dart';
import 'statistics_page.dart';
import 'test_area_button_page.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setting')),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            SettingMenuCard(
              icon: Icons.photo_size_select_large_rounded,
              title: 'Custom Tema',
              subtitle:
                  'Konfigurasi frame pembuka, frame kamera, dan frame hasil',
              color: Color(0xFF5F72EB),
              onTap: () {
                context.push(const CustomTemaPage());
              },
            ),
            SpaceHeight(16),
            SettingMenuCard(
              icon: Icons.smart_button_rounded,
              title: 'Custom Button Tema',
              subtitle: 'Konfigurasi tombol-tombol pada aplikasi',
              color: Color(0xFF7B8FE8),
              onTap: () {
                context.push(const CustomButtonTemaPage());
              },
            ),
            SpaceHeight(16),
            SettingMenuCard(
              icon: Icons.photo_library_rounded,
              title: 'Frame Template',
              subtitle: 'Atur template dan posisi foto pada frame',
              color: Color(0xFF00B8D4),
              onTap: () {
                context.push(const FrameTemplateListPage());
              },
            ),
            SpaceHeight(16),
            SettingMenuCard(
              icon: Icons.touch_app_rounded,
              title: 'Test Area Button',
              subtitle: 'Coba dan test area button yang sudah diatur',
              color: Color(0xFF00B894),
              onTap: () {
                context.push(const TestAreaButtonPage());
              },
            ),
            SpaceHeight(16),
            SettingMenuCard(
              icon: Icons.timer_outlined,
              title: 'Atur Countdown',
              subtitle: 'Atur durasi countdown sebelum foto diambil',
              color: Color(0xFFFF6B6B),
              onTap: () {
                context.push(const CountdownSettingPage());
              },
            ),
            // SpaceHeight(16),
            // SettingMenuCard(
            //   icon: Icons.description_rounded,
            //   title: 'Description WA',
            //   subtitle: 'Atur description yang akan dikirim ke WA',
            //   color: Color(0xFF0984E3),
            //   onTap: () {
            //     context.push(const DescriptionWaPage());
            //   },
            // ),
            SpaceHeight(16),
            SettingMenuCard(
              icon: Icons.print_rounded,
              title: 'Setting Printer',
              subtitle: 'Atur pengaturan printer bluetooth',
              color: Color(0xFF0984E3),
              onTap: () {
                context.push(const SettingPrinterPage());
              },
            ),
            SpaceHeight(16),
            SettingMenuCard(
              icon: Icons.receipt_long_rounded,
              title: 'Voucher',
              subtitle: 'Kelola voucher dan pengaturan akses',
              color: Color(0xFF6C5CE7),
              onTap: () {
                context.push(const GenerateVoucherPage());
              },
            ),
            // SpaceHeight(16),
            // SettingMenuCard(
            //   icon: Icons.analytics_outlined,
            //   title: 'Statistik',
            //   subtitle: 'Lihat ringkasan statistik file aplikasi',
            //   color: Color(0xFF00A896),
            //   onTap: () {
            //     context.push(const StatisticsPage());
            //   },
            // ),
            // SpaceHeight(16),
            // SettingMenuCard(
            //   icon: Icons.vpn_key_rounded,
            //   title: 'Token',
            //   subtitle: 'Kelola token akses aplikasi',
            //   color: Color(0xFF6C5CE7),
            //   onTap: () {
            //     context.push(const GenerateTokenPage());
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
