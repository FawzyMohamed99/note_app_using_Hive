import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hive_nots/edit_note.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  bool bottomSheetOpen = false;
  final notesRef = Hive.box('Notes');
  List<Map<String, dynamic>> notesData = [];
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool searchOpen = false;
  final Random random = Random();

  //fun to add Notes
  void addNote({required String title, required String description}) async {
    await notesRef.add({
      'title': title,
      'description': description,
    });

    //call data from cache
    getNotes();
  }

  void deleteNote({required int noteKey}) async {
    await notesRef.delete(noteKey);
    getNotes();
  }

  void getNotes() {
    setState(() {
      notesData = notesRef.keys.map((e) {
        final currentNote = notesRef.get(e);
        return {
          'key': e,
          'title': currentNote['title'],
          'description': currentNote['description'],
        };
      }).toList();
    });
    debugPrint('Notes length is ${notesData.length}');
  }

  List<Map<String, dynamic>> notesFilter = [];

  void filterNotes({required String input}) {
   setState(() {
     notesFilter = notesData
         .where((element) => element['title']
         .toString()
         .toLowerCase()
         .startsWith(input.toLowerCase()))
         .toList();
   });
  }

  @override
  void initState() {
    // TODO: implement initState
    getNotes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: searchOpen == false
            ? Text('Notes')
            : TextFormField(
          onChanged: (input){
            filterNotes(input: input);
          },
                decoration: InputDecoration(
                  hintText: 'Search Title Notes',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white),
                ),
              ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  searchOpen = !searchOpen;
                });
              },
              child: Icon(searchOpen == false ? Icons.search : Icons.clear),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (bottomSheetOpen == false) {
            scaffoldKey.currentState!
                .showBottomSheet((context) {
                  return Container(
                    color: Colors.grey.withOpacity(.2),
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            hintText: 'Title',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        TextFormField(
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            hintText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Align(
                          alignment: AlignmentDirectional.topEnd,
                          child: MaterialButton(
                            color: Colors.deepPurple,
                            textColor: Colors.white,
                            onPressed: () {
                              if (titleController.text.isNotEmpty &&
                                  descriptionController.text.isNotEmpty) {
                                addNote(
                                    title: titleController.text,
                                    description: descriptionController.text);
                                Navigator.pop(context);
                              } else {
                                _showAlertDialog(context);
                              }
                            },
                            child: Text('Add Note'),
                          ),
                        ),
                      ],
                    ),
                  );
                })
                .closed
                .then((value) {
                  titleController.clear();
                  descriptionController.clear();
                  setState(() {
                    bottomSheetOpen = false;
                  });
                  debugPrint('Closed....');
                });
            setState(() {
              bottomSheetOpen = true;
            });
          } else {
            setState(() {
              bottomSheetOpen = false;
            });
            Navigator.pop(context);
          }
        },
        child: Icon(bottomSheetOpen ? Icons.close : Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView.separated(
            itemBuilder: (context, index) {
              Color randomColor = Color.fromARGB(
                255,
                random.nextInt(256),
                random.nextInt(256),
                random.nextInt(256),
              );
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: randomColor,
                  //  color: Colors.grey.withOpacity(.4),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text( notesFilter.isEmpty?
                      notesData[index]['title'] :
                    notesFilter[index]['title'] ,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      notesFilter.isEmpty?
                      notesData[index]['description'] :
                      notesFilter[index]['description'] ,

                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EditNote(
                                        title: notesData[index]['title'],
                                        description: notesData[index]
                                            ['description'],
                                        noteKey: notesData[index]['key'])));
                          },
                          child: const Icon(Icons.edit),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        GestureDetector(
                          onTap: () async {
                            deleteNote(
                              noteKey: notesData[index]['key'],
                            );
                          },
                          child: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) {
              return const SizedBox(
                height: 13,
              );
            },
            itemCount: notesFilter.isEmpty? notesData.length : notesFilter.length),
      ),
    );
  }
}

Future<void> _showAlertDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.deepOrangeAccent,
        title: const Text('Warning',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: ListBody(
            children: const [Text('Title or Description is Empty')],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              // Perform some action
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
