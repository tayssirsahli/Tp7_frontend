import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tp70/service/matiereservice.dart';
import 'package:tp70/template/dialog/matieredialog.dart';
import 'package:tp70/template/navbar.dart';

import '../entities/matiere.dart';

class MatiereScreen extends StatefulWidget {
  @override
  _MatiereScreenState createState() => _MatiereScreenState();
}

class _MatiereScreenState extends State<MatiereScreen> {
  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavBar('Matières'),
      body: FutureBuilder<List<Matiere>>(
        future: getAllMatieres(),
        builder: (BuildContext context, AsyncSnapshot<List<Matiere>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final List<Matiere> data = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                final matiere = data[index];
                return Slidable(
                  key: Key(matiere.codMat.toString()),
                  startActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) async {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return MatiereDialog(
                                notifyParent: refresh,
                                matiere: matiere,
                              );
                            },
                          );
                        },
                        backgroundColor: const Color(0xFF21B7CA),
                        foregroundColor: Colors.white,
                        icon: Icons.edit,
                        label: 'Modifier',
                      ),
                    ],
                  ),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    dismissible: DismissiblePane(onDismissed: () async {
                      await deleteMatiere(matiere.codMat);
                      refresh();
                    }),
                    children: [],
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text("Matière : "),
                            Text(
                              matiere.intMat,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Text("Description : ${matiere.description}"),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('Aucune matière disponible.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purpleAccent,
        onPressed: () async {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return MatiereDialog(
                notifyParent: refresh,
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
