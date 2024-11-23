import 'package:flutter/material.dart';
import 'package:tp70/service/matiereservice.dart';
import '../../entities/matiere.dart';

class MatiereDialog extends StatefulWidget {
  final Function()? notifyParent;
  final Matiere? matiere;

  MatiereDialog({Key? key, this.notifyParent, this.matiere}) : super(key: key);

  @override
  _MatiereDialogState createState() => _MatiereDialogState();
}

class _MatiereDialogState extends State<MatiereDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController intituleCtrl = TextEditingController();
  TextEditingController descriptionCtrl = TextEditingController();

  String title = "Ajouter Matière";
  bool modif = false;
  late int idMatiere;

  @override
  void initState() {
    super.initState();
    if (widget.matiere != null) {
      modif = true;
      title = "Modifier Matière";
      intituleCtrl.text = widget.matiere!.intMat;
      descriptionCtrl.text = widget.matiere!.description;
      idMatiere = widget.matiere!.codMat;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(title),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: intituleCtrl,
                  validator: (value) => value!.isEmpty ? "Champs obligatoire" : null,
                  decoration: const InputDecoration(labelText: "Intitulé"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: descriptionCtrl,
                  validator: (value) => value!.isEmpty ? "Champs obligatoire" : null,
                  decoration: const InputDecoration(labelText: "Description"),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    if (!modif) {
                      await addMatiere(Matiere(
                        0, // ID will be assigned on creation
                        intituleCtrl.text,
                        descriptionCtrl.text,
                      ));
                    } else {
                      await updateMatiere(Matiere(
                        idMatiere,
                        intituleCtrl.text,
                        descriptionCtrl.text,
                      ));
                    }
                    widget.notifyParent?.call();
                    Navigator.pop(context);
                  }
                },
                child: Text(modif ? "Modifier" : "Ajouter"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
