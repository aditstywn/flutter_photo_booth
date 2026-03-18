import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/style/theme/photo_booth_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/photo_booth/data/datasource/photo_booth_remote_datasource.dart';
import 'features/photo_booth/presentation/bloc/photobooth/photobooth_bloc.dart';
import 'features/photo_booth/presentation/bloc/qrcode/qrcode_bloc.dart';
import 'features/photo_booth/presentation/bloc/settings/settings_bloc.dart';
import 'features/token/data/datasource/token_local_datasource.dart';
import 'features/token/presentation/bloc/token_bloc.dart';

void main() async {
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => TokenLocalDatasource()),
        RepositoryProvider(create: (context) => PhotoBoothRemoteDatasource()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                TokenBloc(context.read<TokenLocalDatasource>()),
          ),
          BlocProvider(
            create: (context) => AuthBloc(context.read<TokenLocalDatasource>()),
          ),
          BlocProvider(
            create: (context) =>
                PhotoboothBloc(context.read<PhotoBoothRemoteDatasource>()),
          ),
          BlocProvider(
            create: (context) =>
                QrcodeBloc(context.read<PhotoBoothRemoteDatasource>()),
          ),

          BlocProvider(
            create: (context) =>
                SettingsBloc(context.read<PhotoBoothRemoteDatasource>()),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Boothera',
          theme: PhotoBoothTheme.lightTheme,
          themeMode: ThemeMode.system,
          // home: const HomePage(),
          home: SplashPage(),
        ),
      ),
    );
  }
}
