import 'package:tp70/entities/matiere.dart';

class Classe {
  int nbreEtud;  // Number of students
  String nomClass;  // Name of the class
  int? codClass;  // Optional class code
  List<Matiere>? matieres;  // List of subjects (optional)

  // Constructor with required parameters and optional ones
  Classe(this.nbreEtud, this.nomClass, {this.codClass, this.matieres});

  // Primary factory constructor for JSON deserialization
  factory Classe.fromJson(Map<String, dynamic> json) {
    return Classe(
      json['nbreEtud'] ?? 0, // Default 0 if null
      json['nomClass'] ?? '', // Default empty string if null
      codClass: json['codClass'], // codClass is optional
      matieres: json['matieres'] != null
          ? (json['matieres'] as List).map((e) => Matiere.fromJson(e)).toList() // Deserialize list of Matiere objects
          : [], // Default empty list if matieres is null
    );
  }

  // Method to convert the class object to JSON
  Map<String, dynamic> toJson() {
    return {
      'nbreEtud': nbreEtud,
      'nomClass': nomClass,
      'codClass': codClass,
      'matieres': matieres?.map((m) => m.toJson()).toList(), // Convert each Matiere to JSON
    };
  }

  // Override equality operator to compare Classe objects
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Classe &&
        other.nomClass == nomClass &&
        other.codClass == codClass;
  }

  // Override hashCode for better performance in collections
  @override
  int get hashCode => nomClass.hashCode ^ codClass.hashCode;
}
