import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_photo_booth/features/auth/presentation/pages/splash_page.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/style/theme/photo_booth_theme.dart';
import 'features/auth/data/datasource/auth_local_datasource.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/home/presentation/pages/home_page.dart';
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
    return RepositoryProvider(
      create: (context) => TokenLocalDatasource(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                TokenBloc(context.read<TokenLocalDatasource>()),
          ),
          BlocProvider(
            create: (context) => AuthBloc(context.read<TokenLocalDatasource>()),
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
