import 'package:buddy_guardian/game/flappy_game.dart';
import 'package:buddy_guardian/screens/puntuaciones_page.dart';
import 'package:buddy_guardian/screens/ranking/ranking_page.dart';
import 'package:buddy_guardian/utils/utils_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GameOverScreen extends StatelessWidget {
  final dynamic userData;
  final FlappyBirdGame game;

  GameOverScreen({super.key, required this.game, this.userData});

  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  Future<void> saveScore(int score, BuildContext context) async {
    if (score == 0) {
      return;
    }

    final firestoreInstance = FirebaseFirestore.instance;

    // Referencia a la colección
    final collection = firestoreInstance.collection('ranking');

    // Buscar el documento del usuario
    final querySnapshot = await collection
        .where('username', isEqualTo: userData['username'])
        .get();
    try {
      if (querySnapshot.docs.isEmpty) {
        // El usuario no existe, crear un nuevo documento
        final id = collection.doc().id;

        final datos = {
          'id': id,
          'id_usuario': userData['id'],
          'username': userData['username'],
          'imageUser': userData['imageUser'],
          'createdAt': DateTime.now(),
          'puntajeTotal': score,
          'puntajeDiario': score,
          'puntajeSemanal': score,
          'puntajeMensual': score,
        };

        print('Datos a guardar: $datos');

        await collection.doc(id).set(datos);

        showSnackbar(context, 'Puntuación guardada');
        print('Puntuación guardada');
      } else {
        // El usuario existe, actualizar el puntaje
        final doc = querySnapshot.docs.first;

        await doc.reference.update({
          'puntajeTotal': FieldValue.increment(score),
          'puntajeDiario': FieldValue.increment(score),
          'puntajeSemanal': FieldValue.increment(score),
          'puntajeMensual': FieldValue.increment(score),
        });
        showSnackbar(context, 'Puntuación actualizada');
        print('Puntuación actualizada');
      }
    } catch (e) {
      print('Error al guardar los datos: $e');
    }
  }

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.black38,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Puntos: ${game.bird.score}',
                style: const TextStyle(
                  fontSize: 60,
                  color: Colors.white,
                  fontFamily: 'Game',
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Fin del Juego',
                style: TextStyle(
                  fontSize: 50,
                  color: Colors.white,
                  fontFamily: 'Game',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => onRestart(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                child: const Text(
                  "Reiniciar",
                  style: TextStyle(
                      fontSize: 20, color: Colors.white, fontFamily: "IB"),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  saveScore(game.bird.score, context);
                  Navigator.pushReplacementNamed(
                    context,
                    '/game',
                    arguments: {'userData': userData},
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                child: const Text(
                  "Ir al Inicio",
                  style: TextStyle(
                      fontSize: 20, color: Colors.white, fontFamily: "IB"),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  saveScore(game.bird.score, context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return RankingPage(userData: userData);
                  }));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                child: const Text(
                  "Puntuaciones",
                  style: TextStyle(
                      fontSize: 20, color: Colors.white, fontFamily: "IB"),
                ),
              ),
            ],
          ),
        ),
      );
  void onRestart(BuildContext context) {
    saveScore(game.bird.score, context);
    game.bird.reset();
    game.overlays.remove('gameOver');
    game.resumeEngine();
  }
}
