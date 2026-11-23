import 'package:flutter/material.dart';
import 'api.dart';
import 'public_screens.dart';
import 'widgets.dart';

// ======================= LOGIN (R2) =======================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await Api.login(_email.text.trim(), _password.text);
      if (!mounted) return;
      // Sostituisce il login con l'area riservata (il tasto "indietro" non torna al login)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } catch (e) {
      if (mounted) showMessage(context, errorText(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login azienda')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              validator: (v) => (v == null || !v.contains('@')) ? 'Email non valida' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.isEmpty) ? 'Campo obbligatorio' : null,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _login,
              child: const Text('Accedi'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
              },
              child: const Text('Non hai un account? Registrati'),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================= REGISTRAZIONE (R1) =======================
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await Api.register(_name.text.trim(), _email.text.trim(), _password.text);
      if (!mounted) return;
      showMessage(context, 'Account creato! Ora puoi accedere.');
      Navigator.pop(context); // torna al login
    } catch (e) {
      if (mounted) showMessage(context, errorText(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrazione azienda')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Nome azienda', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo obbligatorio' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              validator: (v) => (v == null || !v.contains('@')) ? 'Email non valida' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password (min. 6 caratteri)',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.length < 6) ? 'Almeno 6 caratteri' : null,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _register,
              child: const Text('Registrati'),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================= AREA RISERVATA (con R3 - Logout) =======================
// SEGNAPOSTO: la lista degli annunci arriverà nei prossimi passi.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await Api.logout();
    if (!context.mounted) return;
    // Svuota TUTTE le schermate e torna alla bacheca pubblica
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const JobListScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Area riservata'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: const Center(child: Text('Sei autenticato come azienda')),
    );
  }
}