import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import '../entities/matiere.dart';

Future<List<Matiere>> getAllMatieres() async {
  final response = await http.get(Uri.parse('http://localhost:8081/matiere/all'));
  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    // Convertir chaque élément en objet Matiere
    return data.map<Matiere>((item) => Matiere.fromJson(item)).toList();
  } else {
    throw Exception('Échec de récupération des matières');
  }
}




Future<void> addMatiere(Matiere matiere) async {
  await http.post(
    Uri.parse("http://localhost:8081/matiere/add"),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode(<String, dynamic>{
      "intMat": matiere.intMat,
      "description": matiere.description,
    }),
  );
}

Future<void> updateMatiere(Matiere matiere) async {
  await http.put(
    Uri.parse("http://localhost:8081/matiere/update"),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode(<String, dynamic>{
      "codMat": matiere.codMat,
      "intMat": matiere.intMat,
      "description": matiere.description,
    }),
  );
}

Future<void> deleteMatiere(int id) async {
  await http.delete(Uri.parse("http://localhost:8081/matiere/delete?id=$id"));
}