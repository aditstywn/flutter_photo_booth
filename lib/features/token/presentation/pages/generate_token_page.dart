import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_photo_booth/core/component/custom_textformfield.dart';
import 'package:flutter_photo_booth/core/component/space.dart';
import 'package:flutter_photo_booth/core/extensions/build_context_ext.dart';

import '../../../../core/component/buttons.dart';
import '../../../../core/style/color/colors_app.dart';
import '../bloc/token_bloc.dart';

class GenerateTokenPage extends StatefulWidget {
  const GenerateTokenPage({super.key});

  @override
  State<GenerateTokenPage> createState() => _GenerateTokenPageState();
}

class _GenerateTokenPageState extends State<GenerateTokenPage> {
  final TextEditingController _activeDaysController = TextEditingController();
  String? _generatedToken;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generate Token ')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          CustomTextFormField(
            controller: _activeDaysController,
            label: 'Active Days',
            hintText: 'Masukkan jumlah hari aktif untuk token',
            keyboardType: TextInputType.number,
            focusedBorderColor: ColorsApp.primary,
          ),
          SpaceHeight(20),
          BlocConsumer<TokenBloc, TokenState>(
            listener: (context, state) {
              switch (state) {
                case TokenSuccess(:final token):
                  setState(() {
                    _generatedToken = token;
                  });
                  context.showAlertSuccess(
                    message: 'Token generated successfully',
                  );
                  break;
                case ErrorToken(:final message):
                  context.showAlertError(message: message);
                  break;
                default:
              }
            },
            builder: (context, state) {
              switch (state) {
                case LoadingToken():
                  return Button.filled(
                    onPressed: () {},
                    label: 'Generate Token',
                    loading: true,
                    color: ColorsApp.primary,
                  );
              }

              return Button.filled(
                onPressed: () {
                  final activeDays = int.tryParse(_activeDaysController.text);
                  if (activeDays != null) {
                    context.read<TokenBloc>().add(
                      TokenEvent.generateToken(activeDays),
                    );
                  }
                },
                label: 'Generate Token',
                color: ColorsApp.primary,
              );
            },
          ),
          SpaceHeight(20),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorsApp.gray400.withAlpha(50),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _generatedToken ?? 'Salin token jika sudah muncul disini',
                    style: TextStyle(
                      fontSize: 12,
                      color: ColorsApp.textSecondary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(
                      ClipboardData(text: _generatedToken ?? ''),
                    );
                    context.showAlertSuccess(message: 'Token disalin');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ColorsApp.primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.copy_rounded,
                      size: 20,
                      color: ColorsApp.primary,
                    ),
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
