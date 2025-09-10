import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minecraft_server_automation/providers/auth_provider.dart';
import 'package:minecraft_server_automation/widgets/auth_wrapper.dart';

class AppLifecycleHandler extends StatefulWidget {
  const AppLifecycleHandler({super.key});

  @override
  State<AppLifecycleHandler> createState() => AppLifecycleHandlerState();
}

class AppLifecycleHandlerState extends State<AppLifecycleHandler>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Get the AuthProvider from the context
    final authProvider = context.read<AuthProvider>();

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // App is going to background - clear API key cache for security
        authProvider.onAppPaused();
        break;
      case AppLifecycleState.resumed:
        // App is coming back to foreground
        authProvider.onAppResumed();
        break;
      case AppLifecycleState.detached:
        // App is being terminated
        authProvider.onAppPaused();
        break;
      case AppLifecycleState.hidden:
        // App is hidden (iOS specific)
        authProvider.onAppPaused();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const AuthWrapper();
  }
}
