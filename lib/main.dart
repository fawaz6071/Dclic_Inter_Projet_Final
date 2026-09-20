import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'modele/page_auth.dart';
import 'services/data_base.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
   if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }
  final baseDeDonnees = DatabaseUtilisateur();
  await baseDeDonnees.initialisation();
  runApp(MonAppli(baseDeDonnees: baseDeDonnees));
}

class MonAppli extends StatelessWidget {
  final DatabaseUtilisateur baseDeDonnees;

  const MonAppli({super.key, required this.baseDeDonnees});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 58, 71, 183),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Mes notes'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                'assets/images/im1.jpg',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
              const Text('Connectez vous à votre espace de note'),
              InterfaceAuthentification(baseDeDonnees: baseDeDonnees),
            ],
          ),
        ),
      ),
    );
  }
}