import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tp70/entities/classe.dart';
import 'package:tp70/entities/student.dart';
import 'package:tp70/service/studentservice.dart';
import 'package:tp70/template/dialog/studentdialog.dart';

class StudentScreen extends StatefulWidget {
  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  String? _selectedClassId; // ID de la classe sélectionnée
  List<dynamic> _classes = []; // Liste des classes
  List<dynamic> _students = []; // Liste des étudiants pour la classe sélectionnée

  @override
  void initState() {
    super.initState();
    _fetchClasses(); // Récupère les classes dès que l'écran est chargé
  }

  // Récupère la liste des classes
  Future<void> _fetchClasses() async {
    try {
      final classes = await getAllClasses();
      setState(() {
        _classes = classes;
        // Définit la classe par défaut si aucune sélection
        _selectedClassId = classes.isNotEmpty ? classes[0]['codClass'].toString() : null;
        _fetchStudents(); // Charge les étudiants pour la première classe
      });
    } catch (e) {
      print("Erreur lors du chargement des classes : $e");
    }
  }

  // Récupère les étudiants pour la classe sélectionnée
  Future<void> _fetchStudents() async {
    if (_selectedClassId == null) return; // Ne fait rien si aucune classe sélectionnée
    try {
      final students = await fetchStudentsByClass(_selectedClassId);
      setState(() {
        _students = students;
      });
    } catch (e) {
      print("Erreur lors du chargement des étudiants : $e");
    }
  }

  void _showAddStudentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddStudentDialog(
          notifyParent: _fetchStudents, // Rafraîchir la liste après ajout
          selectedClasse: _classes.isNotEmpty
              ? Classe.fromJson(_classes.firstWhere(
                  (classe) => classe['codClass'].toString() == _selectedClassId,
              orElse: () => {}))
              : null, // If no class matches, return null
        );
      },
    );
  }


  // Affiche le formulaire d'édition d'un étudiant
  void _showEditStudentDialog(Student student) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddStudentDialog(
          notifyParent: _fetchStudents, // Rafraîchir la liste après modification
          student: student,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Étudiants"),
      ),
      body: Column(
        children: [
          // DropdownButton pour sélectionner une classe
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _selectedClassId,
              hint: Text("Sélectionnez une classe"),
              isExpanded: true,
              items: _classes.map((classe) {
                return DropdownMenuItem<String>(
                  value: classe['codClass'].toString(),
                  child: Text(classe['nomClass'] ?? "Nom inconnu"),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedClassId = newValue;
                });
                _fetchStudents(); // Met à jour les étudiants en fonction de la classe sélectionnée
              },
            ),
          ),

          // Liste des étudiants pour la classe sélectionnée
          Expanded(
            child: _students.isEmpty
                ? Center(child: Text("Aucun étudiant trouvé pour cette classe."))
                : ListView.builder(
              itemCount: _students.length,
              itemBuilder: (context, index) {
                final student = _students[index];
                return ListTile(
                  title: Text(
                    "${student['nom']} ${student['prenom']}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Date de naissance : ${student['dateNais'] != null ? DateFormat('dd-MM-yyyy').format(DateTime.parse(student['dateNais'])) : 'Inconnue'}",
                  ),
                  onTap: () => _showEditStudentDialog(Student.fromJson(student)), // Ouvrir le formulaire d'édition
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStudentDialog, // Afficher le formulaire d'ajout
        child: Icon(Icons.add),
        backgroundColor: Colors.purpleAccent,
      ),
    );
  }
}
