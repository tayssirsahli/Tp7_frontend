import 'classe.dart';

class Student {
  String ?dateNais, nom, prenom;
  int? id;
  Classe? classe;  // La classe doit être un objet de type Classe

  Student({this.dateNais, this.nom, this.prenom, this.id, this.classe});

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      dateNais: json['dateNais'],
      nom: json['nom'],
      prenom: json['prenom'],
      id: json['id'],
      classe: json['classe'] != null ? Classe.fromJson(json['classe']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dateNais': dateNais,
      'nom': nom,
      'prenom': prenom,
      'id': id,
      'classe': classe?.toJson(),  // On inclut la classe si elle n'est pas null
    };
  }
}
