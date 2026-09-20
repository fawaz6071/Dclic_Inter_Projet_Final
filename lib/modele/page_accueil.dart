import 'package:flutter/material.dart';
import 'package:projet_final/services/data_base.dart';


class PageAccueil extends StatefulWidget {
  final String nomUtilisateur;
  final DatabaseUtilisateur baseDeDonnees;

  const PageAccueil({
    super.key,
    required this.nomUtilisateur,
    required this.baseDeDonnees,
  });

  @override
  State<PageAccueil> createState() => _PageAccueilState();
}

class _PageAccueilState extends State<PageAccueil> {
  List<Map<String, dynamic>> _notes = [];

  @override
  void initState() {
    super.initState();
    _chargerNotes();
  }

  Future<void> _chargerNotes() async {
    final notes = await widget.baseDeDonnees.obtenirNotes(widget.nomUtilisateur);
    if (!mounted) return;
    setState(() {
      _notes = notes;
    });
  }

  Future<void> _ouvrirNouvelleNote() async {
    final ajoutee = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PageNouvelleNote(
          nomUtilisateur: widget.nomUtilisateur,
          baseDeDonnees: widget.baseDeDonnees,
        ),
      ),
    );
    if (ajoutee == true) {
      _chargerNotes();
    }
  }

  // On passe la note à modifier : la page de saisie se remplit avec ses valeurs
  Future<void> _modifierNote(Map<String, dynamic> note) async {
    final modifiee = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PageNouvelleNote(
          nomUtilisateur: widget.nomUtilisateur,
          baseDeDonnees: widget.baseDeDonnees,
          note: note,
        ),
      ),
    );
    if (modifiee == true) {
      _chargerNotes();
    }
  }
  Future<void> _supprimerNote(Map<String, dynamic> note) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la note ?'),
        content: Text('« ${note['titre']} » sera supprimée définitivement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

        if (confirme != true) return;

    await widget.baseDeDonnees.supprimerNote(note['id'] as int);
    await _chargerNotes();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note supprimée')),
    );
  
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Mes notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Se déconnecter',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bonjour ${widget.nomUtilisateur}, Bienvenu dans votre espace de notes',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('Retrouvez ici toutes vos notes.'),
            const SizedBox(height: 8),
            Expanded(
              child: _notes.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.note_alt_outlined,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 12),
                          Text('Aucune note pour le moment'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _notes.length,
                      itemBuilder: (context, index) {
                        final note = _notes[index];
                        return Card(
                          child: ListTile(
                            title: Text(note['titre'] as String),
                            subtitle: Text(
                              note['contenu'] as String,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            // Les deux boutons, côte à côte à droite de la note
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  tooltip: 'Modifier',
                                  onPressed: () => _modifierNote(note),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  tooltip: 'Supprimer',
                                  onPressed: () => _supprimerNote(note),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ouvrirNouvelleNote,
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle note'),
      ),
    );
  }
}

class PageNouvelleNote extends StatefulWidget {
  final String nomUtilisateur;
  final DatabaseUtilisateur baseDeDonnees;
  // null = création d'une note ; sinon = modification de cette note
  final Map<String, dynamic>? note;

  const PageNouvelleNote({
    super.key,
    required this.nomUtilisateur,
    required this.baseDeDonnees,
    this.note,
  });

  @override
  State<PageNouvelleNote> createState() => _PageNouvelleNoteState();
}

class _PageNouvelleNoteState extends State<PageNouvelleNote> {
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _contenuController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // En mode modification, on remplit les champs avec la note existante
    final note = widget.note;
    if (note != null) {
      _titreController.text = note['titre'] as String;
      _contenuController.text = note['contenu'] as String;
    }
  }

  @override
  void dispose() {
    _titreController.dispose();
    _contenuController.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    final titre = _titreController.text.trim();
    final contenu = _contenuController.text.trim();

    if (titre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir un titre')),
      );
      return;
    }

    final note = widget.note;
    if (note == null) {
      await widget.baseDeDonnees.ajouterNote(
        widget.nomUtilisateur,
        titre,
        contenu,
      );
    } else {
      await widget.baseDeDonnees.modifierNote(
        note['id'] as int,
        titre,
        contenu,
      );
    }
    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Nouvelle note' : 'Modifier la note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titreController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Titre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contenuController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Contenu',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _enregistrer,
        icon: const Icon(Icons.check),
        label: const Text('Enregistrer'),
      ),
    );
  }
}