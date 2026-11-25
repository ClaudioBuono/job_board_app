import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'api.dart';
import 'company_screens.dart';
import 'widgets.dart';

// ======================= BACHECA PUBBLICA (R5) =======================
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
    _jobs = Api.getJobs();
  }

  void _reload() {
    setState(() {
      _jobs = Api.getJobs();
    });
  }

  Future<void> _openCompanyArea() async {
    if (!Api.isLoggedIn) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (mounted) _reload();
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
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
          onRefresh: () async => _reload(),
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

// ======================= DETTAGLIO ANNUNCIO (R5 + avvio R6) =======================
class JobDetailScreen extends StatelessWidget {
  final Map<String, dynamic> job;

  const JobDetailScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dettaglio annuncio')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
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
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.send),
              label: const Text('Candidati'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ApplyScreen(
                      jobId: job['id'],
                      jobTitle: job['title'],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ======================= FORM CANDIDATURA (R6) =======================
class ApplyScreen extends StatefulWidget {
  final String jobId;
  final String jobTitle;

  const ApplyScreen({
    super.key,
    required this.jobId,
    required this.jobTitle,
  });

  @override
  State<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends State<ApplyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();

  File? _cvFile;
  String? _cvFileName;
  bool _loading = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.isNotEmpty && result.single.path != null) {
      setState(() {
        _cvFile = File(result.single.path!);
        _cvFileName = result.single.name;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_cvFile == null) {
      showMessage(context, 'Allega il curriculum in formato PDF');
      return;
    }

    setState(() => _loading = true);
    try {
      await Api.applyToJob(
        jobId: widget.jobId,
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        email: _email.text.trim(),
        cvFile: _cvFile!,
      );
      if (!mounted) return;
      showMessage(context, 'Candidatura inviata con successo!');
      Navigator.pop(context); // torna al dettaglio annuncio
    } catch (e) {
      if (mounted) showMessage(context, errorText(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Candidati: ${widget.jobTitle}')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _firstName,
              decoration: const InputDecoration(labelText: 'Nome', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo obbligatorio' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _lastName,
              decoration: const InputDecoration(labelText: 'Cognome', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo obbligatorio' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              validator: (v) => (v == null || !v.contains('@')) ? 'Email non valida' : null,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickPdf,
              icon: const Icon(Icons.upload_file),
              label: Text(_cvFileName ?? 'Allega curriculum (PDF)'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _submit,
              child: const Text('Invia candidatura'),
            ),
          ],
        ),
      ),
    );
  }
}