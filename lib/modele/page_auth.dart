import 'package:flutter/material.dart';
import 'package:projet_final/modele/page_accueil.dart';
import 'package:projet_final/services/data_base.dart';



class InterfaceAuthentification extends StatefulWidget {
  final DatabaseUtilisateur baseDeDonnees;

  const InterfaceAuthentification({super.key, required this.baseDeDonnees});

  @override
  State<InterfaceAuthentification> createState() =>
      _InterfaceAuthentificationState();
}

class _InterfaceAuthentificationState extends State<InterfaceAuthentification> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _motDePasseController = TextEditingController();

  @override
  void dispose() {
    _nomController.dispose();
    _motDePasseController.dispose();
    super.dispose();
  }

  void _afficherMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _seConnecter() async {
    final nom = _nomController.text.trim();
    final motDePasse = _motDePasseController.text;

    if (nom.isEmpty || motDePasse.isEmpty) {
      _afficherMessage('Veuillez remplir tous les champs');
      return;
    }

    final ok = await widget.baseDeDonnees.verifierIdentifiants(nom, motDePasse);
    if (!mounted) return;

        if (ok) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PageAccueil(
            nomUtilisateur: nom,
            baseDeDonnees: widget.baseDeDonnees,
          ),
        ),
      );
      if (!mounted) return;
      _motDePasseController.clear();
    } else {
      _afficherMessage('Nom ou mot de passe incorrect');
    }
  }

  Future<void> _sInscrire() async {
    final nom = _nomController.text.trim();
    final motDePasse = _motDePasseController.text;

    if (nom.isEmpty || motDePasse.isEmpty) {
      _afficherMessage('Veuillez remplir tous les champs');
      return;
    }

    if (await widget.baseDeDonnees.nomExiste(nom)) {
      if (!mounted) return;
      _afficherMessage('Ce nom est déjà utilisé');
      return;
    }

    await widget.baseDeDonnees.inscrire(nom, motDePasse);
    if (!mounted) return;
    _afficherMessage('Compte créé, vous pouvez vous connecter');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _nomController,
            decoration: const InputDecoration(
              labelText: 'Nom',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _motDePasseController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Mot de passe',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _seConnecter,
            child: const Text('Se connecter'),
          ),
          TextButton(
            onPressed: _sInscrire,
            child: const Text('Créer un compte'),
          ),
        ],
      ),
    );
  }
}