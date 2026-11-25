import 'package:flutter/material.dart';
import 'api.dart';
import 'company_screens.dart';
import 'public_screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Api.loadToken(); // carica l'eventuale token salvato
  runApp(const JobBoardApp());
}

class JobBoardApp extends StatelessWidget {
  const JobBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bacheca Annunci',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      // Se l'azienda è già loggata apre subito la Dashboard (I miei annunci / candidature),
      // altrimenti apre la bacheca pubblica.
      home: Api.isLoggedIn ? const DashboardScreen() : const JobListScreen(),
    );
  }
}