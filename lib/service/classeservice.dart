import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:tp70/entities/Student.dart';
import 'package:tp70/entities/classe.dart';
import 'package:tp70/entities/student.dart';
import '../entities/matiere.dart';

// Function to get all classes
Future<List<Map<String, dynamic>>> getAllClasses() async {
  try {
    final response = await http.get(Uri.parse("http://localhost:8081/class/all"));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load classes');
    }
  } catch (e) {
    print("Error: $e");
    return [];
  }
}


// Function to delete a class by ID
Future deleteClass(int id) {
  return http.delete(Uri.parse("http://localhost:8081/class/delete?id=${id}"));
}

Future<String> addClass(Classe classe, List<Matiere> matieres) async {
  // Ajouter la liste des matières à l'objet classe avant d'envoyer
  classe.matieres = matieres;

  // Étape 1: Ajouter la classe et les relations classMat dans la même requête
  Response response = await http.post(
    Uri.parse("http://localhost:8081/class/add"),
    headers: {"Content-type": "application/json"},
    body: jsonEncode(<String, dynamic>{
      "nomClass": classe.nomClass,
      "nbreEtud": classe.nbreEtud,
      "matieres": List<dynamic>.from(
        matieres.map((matiere) => {
          "codMat": matiere.codMat,  // Assurez-vous de passer les identifiants des matières
        }),
      ),
    }),
  );

  // Étape 2: Vérification de la réussite de l'ajout
  if (response.statusCode == 200) {
    return "Classe ajoutée avec succès"; // Retourner un message de succès
  } else {
    return "Échec de l'ajout de la classe"; // Si l'ajout échoue
  }
}

// Function to update a class and the related ClassMat relationships
Future updateClasse(Classe classe, List<Matiere> matieres) async {
  // Step 1: Update the class in the `classe` table
  Response response = await http.put(
    Uri.parse("http://localhost:8081/class/update"),
    headers: {"Content-type": "Application/json"},
    body: jsonEncode(<String, dynamic>{
      "codClass": classe.codClass,
      "nomClass": classe.nomClass,
      "nbreEtud": classe.nbreEtud,
    }),
  );

  // Step 2: If class update was successful, update ClassMat relationships
  if (response.statusCode == 200) {
    // First, delete existing ClassMat relationships for this class
    await http.delete(Uri.parse("http://localhost:8081/classMat/delete?codClass=${classe.codClass}"));

    // Then, add the new relationships with the updated list of matieres
    List<int> matiereIds = matieres.map((matiere) => matiere.codMat).toList();
    for (var matiereId in matiereIds) {
      await http.post(
        Uri.parse("http://localhost:8081/classMat/add"),
        headers: {"Content-type": "Application/json"},
        body: jsonEncode(<String, dynamic>{
          "codClass": classe.codClass,
          "codMatiere": matiereId,
        }),
      );
    }
  }

  return response.body;
}

//Function to get the list of matieres by class
Future<List<Matiere>> getMatiereByClasse(int codClass) async {
  final response = await http.get(Uri.parse('http://localhost:8081/classes/$codClass/matieres'));
  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    // Convert each item in the dynamic list to a Matiere object
    return data.map<Matiere>((item) => Matiere.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load matieres');
  }
}

