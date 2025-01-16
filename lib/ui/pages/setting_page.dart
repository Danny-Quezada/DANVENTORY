import 'package:danventory/providers/user_provider.dart';
import 'package:danventory/ui/pages/initial_page.dart';
import 'package:danventory/ui/utils/theme_setting.dart';
import 'package:danventory/ui/widgets/safe_scaffold.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return SafeScaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            ElevatedButton(
                style: const ButtonStyle(
                    backgroundColor:
                        WidgetStatePropertyAll(ThemeSetting.redColor)),
                onPressed: () async {
                  await userProvider.closeSession();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const InitialPage();
                      },
                    ),
                    (route) => false,
                  );
                },
                child: const Text('Cerrar sesión')),
          ],
        ),
      ),
    );
  }
}