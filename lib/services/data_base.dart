import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Creation de la base Utilisateur
class DatabaseUtilisateur {
  late Database _database;

  // Initialisation de la base, ici il s'agit de la base d'authentification
  Future<void> initialisation() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'utilisateurs_database.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE authen(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nom TEXT,
            motdepass TEXT
          )
        ''');
        await _creerTableNotes(db);
      },
      // on ajoute seulement la table notes à la base utilisateur
      onUpgrade: (db, ancienneVersion, nouvelleVersion) async {
        if (ancienneVersion < 2) {
          await _creerTableNotes(db);
        }
      },
      version: 2,
    );
  }

  Future<void> _creerTableNotes(Database db) {
    return db.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titre TEXT,
        contenu TEXT,
        date_creation TEXT,
        proprietaire TEXT
      )
    ''');
  }

  Future<List<Map<String, dynamic>>> obtenirUtilisateurs() {
    return _database.query('authen');
  }

  Future<bool> nomExiste(String nom) async {
    final resultat = await _database.query(
      'authen',
      where: 'nom = ?',
      whereArgs: [nom],
      limit: 1,
    );
    return resultat.isNotEmpty;
  }

  // On verifie les infos de connexion de l'utilisateur
  Future<void> inscrire(String nom, String motDePasse) async {
    await _database.insert('authen', {
      'nom': nom,
      'motdepass': motDePasse,
    });
  }

  Future<bool> verifierIdentifiants(String nom, String motDePasse) async {
    final resultat = await _database.query(
      'authen',
      where: 'nom = ? AND motdepass = ?',
      whereArgs: [nom, motDePasse],
      limit: 1,
    );
    return resultat.isNotEmpty;
  }

  // Apres verification acces à la page d'acceuil avec ajout des notes
  Future<void> ajouterNote(
      String proprietaire, String titre, String contenu) async {
    await _database.insert('notes', {
      'titre': titre,
      'contenu': contenu,
      'date_creation': DateTime.now().toIso8601String(),
      'proprietaire': proprietaire,
    });
  }

  // Les notes d'un utilisateur, la plus récente en premier
  Future<List<Map<String, dynamic>>> obtenirNotes(String proprietaire) {
    return _database.query(
      'notes',
      where: 'proprietaire = ?',
      whereArgs: [proprietaire],
      orderBy: 'id DESC',
    );
  }

  Future<void> modifierNote(int id, String titre, String contenu) async {
    await _database.update(
      'notes',
      {'titre': titre, 'contenu': contenu},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> supprimerNote(int id) async {
    await _database.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> fermer() async {
    await _database.close();
  }
}