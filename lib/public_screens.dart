import 'package:flutter/material.dart';
import 'api.dart';
import 'company_screens.dart';
import 'widgets.dart';

// SEGNAPOSTO: la vera bacheca arriverà nel prossimo passo.
class JobListScreen extends StatefulWidget {

  const JobListScreen({super.key});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  late Future<List<dynamic>> _jobs;

  @override
  void initState() {
    super.initState();
    _jobs = Api.getJobs(); // parte subito la richiesta al server
  }

  void _reload() {
    setState(() {
      _jobs = Api.getJobs();
    });
  }

  Future<void> _openCompanyArea() async {
    // Se l'azienda non è loggata, prima passa dal login.
    // Il login, se va a buon fine, torna indietro con il valore "true".
    if (!Api.isLoggedIn) {
      final ok = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (ok != true || !mounted) return;
    }
    // Apre l'area riservata e aspetta che l'utente torni indietro...
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
    // ...poi ricarica la bacheca: così compaiono gli annunci appena pubblicati.
    if (mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bacheca annunci'),
        actions: [
          IconButton(
            icon: const Icon(Icons.business),
            tooltip: 'Area azienda',
            onPressed: _openCompanyArea,
          ),
        ],
      ),
      body: ListLoader(
        future: _jobs,
        onRetry: _reload,
        emptyText: 'Nessun annuncio pubblicato',
        builder: (jobs) => RefreshIndicator(
          onRefresh: () async => _reload(), // trascina verso il basso per aggiornare
          child: ListView.builder(
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return ListTile(
                title: Text(job['title']),
                subtitle: Text(job['companyName']),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

// ======================= DETTAGLIO ANNUNCIO (R5) =======================
// Il pulsante "Candidati" arriverà con R6.
class JobDetailScreen extends StatelessWidget {
  final Map<String, dynamic> job;

  const JobDetailScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dettaglio annuncio')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(job['title'], style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(job['companyName'], style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              Text(job['description']),
            ],
          ),
        ),
      ),
    );
  }
}
