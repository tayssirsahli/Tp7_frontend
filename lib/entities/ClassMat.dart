class ClassMat {
  int? id;            // ID of the class-matter relation
  int? codClass;      // Class code
  int? codMat;        // Matter code
  double coefMat;     // Coefficient of the matter
  double nbrHS;       // Number of hours for the matter

  // Constructor
  ClassMat({
    this.id,
    required this.codClass,
    required this.codMat,
    required this.coefMat,
    required this.nbrHS,
  });

  // Method to convert the object into a Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,              // Nullable id, may be null
      'codClass': codClass,  // Class code
      'codMat': codMat,      // Matter code
      'coefMat': coefMat,    // Coefficient
      'nbrHS': nbrHS,        // Hours
    };
  }

  // Factory method to convert JSON to ClassMat object
  factory ClassMat.fromJson(Map<String, dynamic> json) {
    return ClassMat(
      id: json['id'],  // 'id' could be null or an integer
      codClass: json['codClass'],
      codMat: json['codMat'],
      coefMat: (json['coefMat'] as num?)?.toDouble() ?? 0.0,  // Ensure it is a double
      nbrHS: (json['nbrHS'] as num?)?.toDouble() ?? 0.0,      // Ensure it is a double
    );
  }

  // Override == operator for equality comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClassMat &&
        other.codClass == codClass &&
        other.codMat == codMat &&
        other.coefMat == coefMat &&
        other.nbrHS == nbrHS;
  }

  // Override hashCode to match equality
  @override
  int get hashCode => codClass.hashCode ^ codMat.hashCode ^ coefMat.hashCode ^ nbrHS.hashCode;
}
