import 'package:flutter/material.dart';
import 'api.dart';

void showMessage(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

// Widget riutilizzabile: mostra caricamento / errore / lista vuota / lista.
// "builder" è una funzione che passiamo noi e che costruisce la lista vera.
class ListLoader extends StatelessWidget {
  final Future<List<dynamic>> future;
  final VoidCallback onRetry;
  final String emptyText;
  final Widget Function(List<dynamic> items) builder;

  const ListLoader({
    super.key,
    required this.future,
    required this.onRetry,
    required this.emptyText,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Errore: ${errorText(snapshot.error!)}', textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: onRetry, child: const Text('Riprova')),
                ],
              ),
            ),
          );
        }
        final items = snapshot.data!;
        if (items.isEmpty) {
          return Center(child: Text(emptyText));
        }
        return builder(items);
      },
    );
  }
}