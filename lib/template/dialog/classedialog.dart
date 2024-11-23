import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:tp70/entities/matiere.dart';
import 'package:tp70/service/classeservice.dart';
import '../../entities/classe.dart';
import '../../service/matiereservice.dart';

class ClassDialog extends StatefulWidget {
  final Function notifyParent;
  final Classe? classe;
  final List<Matiere> matieres;

  ClassDialog({required this.notifyParent, this.classe, required this.matieres});

  @override
  _ClassDialogState createState() => _ClassDialogState();
}

class _ClassDialogState extends State<ClassDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nomClassController = TextEditingController();
  TextEditingController _nbreEtudController = TextEditingController();
  List<Matiere> _selectedMatieres = [];
  late Future<List<Matiere>> _matieresList;

  @override
  void initState() {
    super.initState();
    _matieresList = getAllMatieres();  // Récupérer toutes les matières
    if (widget.classe != null) {
      _nomClassController.text = widget.classe!.nomClass;
      _nbreEtudController.text = widget.classe!.nbreEtud.toString();
      // Initialiser les matières sélectionnées
      _selectedMatieres = widget.matieres
          .where((matiere) => widget.classe!.matieres != null && widget.classe!.matieres!.contains(matiere.codMat))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.classe == null ? 'Ajouter une classe' : 'Modifier la classe'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Nom de la classe
            TextFormField(
              controller: _nomClassController,
              decoration: InputDecoration(labelText: 'Nom de la classe'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un nom';
                }
                return null;
              },
            ),
            // Nombre d'étudiants
            TextFormField(
              controller: _nbreEtudController,
              decoration: InputDecoration(labelText: 'Nombre d\'étudiants'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un nombre';
                }
                // Vérifier si l'entrée est un nombre valide
                try {
                  int.parse(value);
                } catch (e) {
                  return 'Veuillez entrer un nombre valide';
                }
                return null;
              },
            ),
            // Sélection des matières
            FutureBuilder<List<Matiere>>(
              future: _matieresList,  // Récupérer la liste des matières
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Erreur: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('Aucune matière disponible');
                } else {
                  return MultiSelectDialogField(
                    items: snapshot.data!.map((Matiere matiere) {
                      return MultiSelectItem<Matiere>(matiere, matiere.intMat);  // Afficher le nom de la matière
                    }).toList(),
                    initialValue: _selectedMatieres,
                    title: Text('Sélectionner des matières'),
                    onConfirm: (values) {
                      setState(() {
                        _selectedMatieres = List<Matiere>.from(values);
                      });
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        // Bouton Annuler
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Annuler'),
        ),
        // Bouton Enregistrer
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              if (widget.classe == null) {
                // Ajouter une nouvelle classe
                final classe = Classe(
                  _nbreEtudController.text.isNotEmpty ? int.parse(_nbreEtudController.text) : 0,
                  _nomClassController.text,
                  matieres: _selectedMatieres,
                );
                await addClass(classe, _selectedMatieres);
              } else {
                // Mettre à jour la classe existante
                final classe = Classe(
                  widget.classe!.nbreEtud,
                  _nomClassController.text,
                  codClass: widget.classe!.codClass,
                  matieres: _selectedMatieres,
                );
                await updateClasse(classe, _selectedMatieres);
              }
              widget.notifyParent();
              Navigator.of(context).pop();
            }
          },
          child: Text('Enregistrer'),
        ),
      ],
    );
  }
}
