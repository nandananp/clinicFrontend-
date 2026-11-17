import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() async {
    usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: '.env');

  runApp(
    const ProviderScope(
      child: ClinicApp(),
    ),
  );
}
