import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:tp70/entities/classe.dart';
import 'package:tp70/entities/student.dart';

Future getAllStudent() async {
  Response response = await http.get(Uri.parse("http://localhost:8081/etudiant/all"));
  return jsonDecode(response.body); // Accédez à la clé contenant la liste d'étudiants
}


Future deleteStudent(int id) {
  return http
      .delete(Uri.parse("http://localhost:8081/etudiant/delete?id=${id}"));
}

Future addStudent(Student student) async {
  print("Nom: ${student.nom}, Prénom: ${student.prenom}, Date de naissance: ${student.dateNais}");
  print("ID Classe: ${student.classe?.codClass}");  // Vérifiez que la classe est bien sélectionnée

  Response response = await http.post(
    Uri.parse("http://localhost:8081/etudiant/add"),
    headers: {"Content-type": "application/json"},
    body: jsonEncode(<String, dynamic>{
      "nom": student.nom,
      "prenom": student.prenom,
      // Ensure dateNais is not null before parsing
      "dateNais": student.dateNais != null
          ? DateFormat("yyyy-MM-dd").format(DateTime.parse(student.dateNais!))
          : "", // Or provide a default value like empty string or some other value
      "classe": {
        "codClass": student.classe?.codClass,
      },
    }),
  );



  print("Réponse du serveur : ${response.body}");  // Affiche la réponse pour débogage
  return response.body;
}


Future updateStudent(Student student) async {
  final response = await http.put(
    Uri.parse("http://localhost:8081/etudiant/update"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "nom": student.nom,
      "prenom": student.prenom,
      "dateNais": student.dateNais,
      "classe": student.classe != null ? {
        "codClass": student.classe!.codClass, // Ensure the 'classe' is mapped correctly
      } : null,
    }),
  );

  if (response.statusCode == 200) {
    print("Mise à jour réussie : ${response.body}");
  } else {
    print("Erreur : ${response.statusCode}");
  }
}

Future<List<dynamic>> fetchStudentsByClass(String? classId) async {
  final url = classId == null
      ? "http://localhost:8081/etudiant/all"
      : "http://localhost:8081/etudiant/byClass?classeId=$classId";
  final response = await http.get(Uri.parse(url));
  return List<dynamic>.from(jsonDecode(response.body));
}

Future<List<dynamic>> getAllClasses() async {
  final response =
  await http.get(Uri.parse("http://localhost:8081/class/all"));

  // Affichez la réponse brute pour vérifier son format
  print("Réponse brute : ${response.body}");

  final data = jsonDecode(response.body);

  // Si la réponse est une liste directement, retournez-la
  if (data is List) {
    return List<dynamic>.from(data);
  } else {
    throw Exception("Format de réponse incorrect pour les classes");
  }
}
