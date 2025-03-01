import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';

import 'package:server/server.dart';

import 'pages/home_page.dart';
import 'theme/theme_cubit.dart';
import 'theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final WindowManager wm = WindowManager.instance;
  await wm.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1120, 800),
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: false,
    minimumSize: Size(896, 640),
  );
  wm.waitUntilReadyToShow(windowOptions, () async {
    await wm.show();
    await wm.focus();
  });
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Server>(
      future: Server.init(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return MultiRepositoryProvider(
          providers: [
            RepositoryProvider(
              create: (context) => snapshot.data!,
            ),
            RepositoryProvider(
              create: (context) => GetStorage(),
            ),
            BlocProvider<ThemeCubit>(
              create: (context) => ThemeCubit(),
            ),
          ],
          child: BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, state) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'EConnect - Tamilnad Mercantile Bank Ltd',
                theme: lightTheme,
                darkTheme: darkTheme,
                themeMode: context.watch<ThemeCubit>().state,
                home: const HomePage(),
              );
            },
          ),
        );
      },
    );
  }
}
