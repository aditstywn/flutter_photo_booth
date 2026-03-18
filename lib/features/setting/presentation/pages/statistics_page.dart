import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_photo_booth/core/extensions/build_context_ext.dart';

import '../../../../core/component/buttons.dart';
import '../../../../core/component/space.dart';
import '../../../../core/style/color/colors_app.dart';
import '../../../photo_booth/presentation/bloc/photobooth/photobooth_bloc.dart';
import '../../../photo_booth/presentation/bloc/settings/settings_bloc.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(const SettingsEvent.statistic());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistik File'), centerTitle: true),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          switch (state) {
            case LoadingSettings():
              return const Center(child: CircularProgressIndicator());
            case StatisticSuccess(:final statistic):
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<SettingsBloc>().add(
                    const SettingsEvent.statistic(),
                  );
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _StatisticTile(
                      icon: Icons.folder_outlined,
                      title: 'Total File',
                      value: statistic.data?.totalFiles.toString() ?? '0',
                      helper: 'Jumlah file yang berhasil diproses',
                    ),

                    const SpaceHeight(12),
                    _StatisticTile(
                      icon: Icons.sd_storage_outlined,
                      title: 'Total Ukuran',
                      value: statistic.data?.totalSize ?? '0',
                      helper: 'Ukuran yang sudah diformat',
                    ),
                    const SpaceHeight(12),
                    _StatisticTile(
                      icon: Icons.report_problem_outlined,
                      title: 'File Hilang',
                      value: statistic.data?.missingFiles.toString() ?? '0',
                      helper: 'Jumlah file yang tidak ditemukan',
                      isAlert: (statistic.data?.missingFiles ?? 0) > 0,
                    ),
                    const SpaceHeight(20),
                    BlocConsumer<PhotoboothBloc, PhotoboothState>(
                      listener: (context, state) {
                        switch (state) {
                          case DeleteAllFileSuccess():
                            context.showAlertSuccess(
                              message: 'Semua file berhasil dihapus',
                            );
                            context.read<SettingsBloc>().add(
                              const SettingsEvent.statistic(),
                            );
                          case ErrorPhotobooth(:final error):
                            context.showAlertError(message: error);

                          case _:
                        }
                      },
                      builder: (context, state) {
                        if (state is LoadingPhotobooth) {
                          return Button.filled(
                            onPressed: () {},
                            label: 'Hapus Semua File',
                            color: ColorsApp.error,
                            loading: true,
                          );
                        }
                        return Button.filled(
                          onPressed: () {
                            context.read<PhotoboothBloc>().add(
                              const PhotoboothEvent.deleteAllFile(),
                            );
                          },
                          label: 'Hapus Semua File',
                          color: ColorsApp.error,
                        );
                      },
                    ),
                  ],
                ),
              );

            case ErrorSettings(:final error):
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: ColorsApp.error, size: 48),
                    const SpaceHeight(12),
                    Text(
                      'Gagal memuat statistik',
                      style: TextStyle(
                        color: ColorsApp.gray700,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SpaceHeight(8),
                    Text(
                      error,
                      style: TextStyle(color: ColorsApp.gray500, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            case _:
              return SizedBox();
          }
        },
      ),
    );
  }
}

class _StatisticTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String helper;
  final bool isAlert;

  const _StatisticTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.helper,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = isAlert ? ColorsApp.error : ColorsApp.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorsApp.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accent.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent),
          ),
          const SpaceWidth(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: ColorsApp.gray600,
                  ),
                ),
                const SpaceHeight(2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: ColorsApp.gray900,
                  ),
                ),
                const SpaceHeight(4),
                Text(
                  helper,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ColorsApp.gray500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
