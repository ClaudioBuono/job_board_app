import 'package:flutter/material.dart';
import 'api.dart';
import 'public_screens.dart';

Future<void> main() async {
  // Serve perché usiamo codice asincrono prima di runApp
  WidgetsFlutterBinding.ensureInitialized();
  await Api.loadToken(); // recupera l'eventuale login salvato sul telefono
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bacheca Lavoro',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      // La schermata iniziale è pubblica: il candidato non fa login
      home: const JobListScreen(),
    );
  }
}