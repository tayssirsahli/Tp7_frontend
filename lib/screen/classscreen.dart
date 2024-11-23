import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tp70/entities/matiere.dart';
import 'package:tp70/service/classeservice.dart';
import 'package:tp70/template/dialog/classedialog.dart';
import 'package:tp70/template/navbar.dart';
import 'package:tp70/entities/classe.dart';
import '../entities/matiere.dart';
import '../service/matiereservice.dart';

class ClasseScreen extends StatefulWidget {
  @override
  _ClasseScreenState createState() => _ClasseScreenState();
}

class _ClasseScreenState extends State<ClasseScreen> {
  List<Matiere> _matieres = [];

  @override
  void initState() {
    super.initState();
    _loadMatieres();
  }

  // Load all matieres when the screen is initialized
  _loadMatieres() async {
    _matieres = await getAllMatieres();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavBar('Classes'), // Custom navbar
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getAllClasses(),
        builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: const Text('No classes found.'));
          }

          // Extract the list of classes from snapshot data
          var classes = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: classes.length,
            itemBuilder: (BuildContext context, int index) {
              var classe = classes[index];

              return Slidable(
                key: Key(classe['codClass'].toString()),
                startActionPane: ActionPane(
                  motion: ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) async {
                        // Open dialog for editing class
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return ClassDialog(
                              notifyParent: () => setState(() {}),
                              classe: Classe(
                                classe['nbreEtud'],
                                classe['nomClass'],
                                codClass: classe['codClass'],
                              ),
                              matieres: _matieres,
                            );
                          },
                        );
                      },
                      backgroundColor: Color(0xFF21B7CA),
                      foregroundColor: Colors.white,
                      icon: Icons.edit,
                      label: 'Edit',
                    ),
                  ],
                ),
                endActionPane: ActionPane(
                  motion: ScrollMotion(),
                  dismissible: DismissiblePane(
                    onDismissed: () async {
                      // Delete class and update UI
                      await deleteClass(classe['codClass']);
                      setState(() {
                        classes.removeAt(index);
                      });
                    },
                  ),
                  children: [Container()],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text("Classe : "),
                              Text(
                                classe['nomClass'],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 2.0),
                            ],
                          ),
                          Text("Nombre étudiants : ${classe['nbreEtud']}"),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purpleAccent,
        onPressed: () async {
          // Open dialog to add a new class
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return ClassDialog(
                notifyParent: () => setState(() {}),
                matieres: _matieres,
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
