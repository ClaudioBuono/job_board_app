import 'package:flutter/material.dart';
import 'api.dart';
import 'company_screens.dart';

// SEGNAPOSTO: la vera bacheca arriverà nel prossimo passo.
class JobListScreen extends StatelessWidget {
  const JobListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bacheca annunci'),
        actions: [
          IconButton(
            icon: const Icon(Icons.business),
            tooltip: 'Area azienda',
            onPressed: () {
              // Se l'azienda è già loggata va all'area riservata, altrimenti al login
              final Widget page = Api.isLoggedIn ? const DashboardScreen() : const LoginScreen();
              Navigator.push(context, MaterialPageRoute(builder: (_) => page));
            },
          ),
        ],
      ),
      body: const Center(child: Text('Bacheca pubblica (in costruzione)')),
    );
  }
}