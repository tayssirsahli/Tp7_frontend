import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../../entities/classe.dart';
import '../../entities/student.dart';
import '../../service/studentservice.dart';

class AddStudentDialog extends StatefulWidget {
  final VoidCallback notifyParent; // Non-nullable for mandatory usage
  final Student? student;
  final Classe ?selectedClasse;

  AddStudentDialog({
    super.key,
    required this.notifyParent,
    this.student,
     this.selectedClasse,
  });

  @override
  State<AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends State<AddStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomCtrl = TextEditingController();
  final TextEditingController _prenomCtrl = TextEditingController();
  final TextEditingController _dateCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  bool _isEditMode = false;
  Classe? _selectedClasse;
  List<Classe> _classes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Fetch classes on initialization
    _fetchClasses();

    // Set initial data if editing
    if (widget.student != null) {
      _isEditMode = true;
      _nomCtrl.text = widget.student!.nom ?? '';
      _prenomCtrl.text = widget.student!.prenom ?? '';
      _dateCtrl.text = widget.student!.dateNais != null
          ? DateFormat("yyyy-MM-dd").format(DateTime.parse(widget.student!.dateNais!))
          : '';
      _selectedClasse = widget.student!.classe;
    }
  }

  Future<void> _fetchClasses() async {
    try {
      final response = await http.get(Uri.parse("http://localhost:8081/class/all"));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _classes = data.map((item) => Classe.fromJson(item)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load classes");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading classes: $e")),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2015),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dateCtrl.text = DateFormat("yyyy-MM-dd").format(_selectedDate);
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      try {
        final student = Student(
          nom: _nomCtrl.text,
          prenom: _prenomCtrl.text,
          dateNais: DateFormat("yyyy-MM-dd").format(_selectedDate),
          classe: _selectedClasse,
          id: widget.student?.id ?? 0, // Use existing ID if editing
        );

        if (_isEditMode) {
          await updateStudent(student);
        } else {
          await addStudent(student);
        }

        widget.notifyParent();
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditMode ? "Modifier Étudiant" : "Ajouter Étudiant"),
      content: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomCtrl,
                decoration: const InputDecoration(labelText: "Nom"),
                validator: (value) => value == null || value.isEmpty ? "Champs est obligatoire" : null,
              ),
              TextFormField(
                controller: _prenomCtrl,
                decoration: const InputDecoration(labelText: "Prénom"),
                validator: (value) => value == null || value.isEmpty ? "Champs est obligatoire" : null,
              ),
              TextFormField(
                controller: _dateCtrl,
                readOnly: true,
                decoration: const InputDecoration(labelText: "Date de naissance"),
                onTap: () => _selectDate(context),
              ),
              DropdownButtonFormField<Classe>(
                value: _selectedClasse,
                items: _classes.map((classe) {
                  return DropdownMenuItem<Classe>(
                    value: classe,
                    child: Text(classe.nomClass),
                  );
                }).toList(),
                onChanged: (Classe? newValue) {
                  setState(() {
                    _selectedClasse = newValue;
                  });
                },
                decoration: const InputDecoration(labelText: 'Classe'),
                validator: (value) => value == null ? "Veuillez sélectionner une classe valide" : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Annuler"),
        ),
        ElevatedButton(
          onPressed: _handleSubmit,
          child: Text(_isEditMode ? "Modifier" : "Ajouter"),
        ),
      ],
    );
  }
}
