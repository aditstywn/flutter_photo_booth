import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_photo_booth/core/component/custom_textformfield.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/style/color/colors_app.dart';
import '../../data/datasource/auth_local_datasource.dart';

import '../../../../core/component/buttons.dart';
import '../../../../core/component/space.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _tokenController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/Body.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/title.png', width: 400),
                SpaceHeight(40),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ColorsApp.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(50),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomTextFormField(
                        controller: _tokenController,
                        label: 'Token',
                        hintText: 'Masukkan token Anda',
                      ),
                      SpaceHeight(20),
                      BlocConsumer<AuthBloc, AuthState>(
                        listener: (context, state) {
                          switch (state) {
                            case LoginSuccess(:final response):
                              AuthLocalDatasource().saveExpiredAt(
                                response.expiredAt.toString(),
                              );
                              context.showAlertSuccess(
                                message: 'Login successful',
                              );
                              context.pushReplacement(const HomePage());
                              break;
                            case ErrorAuth(:final message):
                              context.showAlertError(message: message);
                              break;
                            default:
                          }
                        },
                        builder: (context, state) {
                          if (state is LoadingAuth) {
                            return Button.filled(
                              onPressed: () {},
                              label: 'Login',
                              loading: true,
                              color: ColorsApp.primary,
                            );
                          }
                          return Button.filled(
                            onPressed: () {
                              if (_tokenController.text.isNotEmpty) {
                                context.read<AuthBloc>().add(
                                  AuthEvent.login(_tokenController.text),
                                );
                              } else {
                                context.showAlertError(
                                  message: 'Token cannot be empty',
                                );
                              }
                            },
                            label: 'Login',
                            color: ColorsApp.primary,
                          );
                        },
                      ),
                    ],
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
