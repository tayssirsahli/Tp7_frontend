class Matiere {
  final int codMat;         // Code of the subject
  final String intMat;      // Title of the subject
  final String description; // Description of the subject

  // Constructor
  Matiere(this.codMat, this.intMat, this.description);

  // Factory method to create a Matiere object from JSON with error handling
  factory Matiere.fromJson(Map<String, dynamic> json) {
    try {
      return Matiere(
        json['codMat'] is int ? json['codMat'] : 0, // Default to 0 if null or not an int
        json['intMat'] is String ? json['intMat'] : '', // Default to empty string if null or not a String
        json['description'] is String ? json['description'] : '', // Default to empty string if null or not a String
      );
    } catch (e) {
      print('Error parsing Matiere from JSON: $e');
      return Matiere(0, '', ''); // Return a default Matiere in case of error
    }
  }

  // Convert a Matiere object to JSON
  Map<String, dynamic> toJson() {
    return {
      'codMat': codMat,
      'intMat': intMat,
      'description': description,
    };
  }

  // Override == operator for equality based on `codMat`
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Matiere &&
        other.codMat == codMat &&
        other.intMat == intMat &&
        other.description == description;
  }

  // Override hashCode for better performance in collections
  @override
  int get hashCode => codMat.hashCode ^ intMat.hashCode ^ description.hashCode;
}
