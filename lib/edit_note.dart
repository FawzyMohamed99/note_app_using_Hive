import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hive_nots/home_screen.dart';

class EditNote extends StatelessWidget {
 final String title,description;
 final int noteKey;
 final titleController=TextEditingController();
 final desController=TextEditingController();
 final notesRef = Hive.box('Notes');
  EditNote({Key? key,required this.title,required this.description,required this.noteKey}) : super(key: key);


  void updateNote(){
    notesRef.put(noteKey, {
      'title':titleController.text,
      'description':desController.text,
    });
  }


  @override
  Widget build(BuildContext context) {
    titleController.text=title;
    desController.text=description;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: ()
         {
          if(titleController.text != title || desController.text != description)
            {
              updateNote();
              Navigator.push(context, MaterialPageRoute(builder: (context)=>HomeScreen()));           }
          else{
            _showAlertDialog(context);
          }
        },
        child: Icon(Icons.edit),
      ),
      appBar: AppBar(title: Text('Edit Note'),automaticallyImplyLeading: false,elevation: 0,),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children:
          [
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(
                border: UnderlineInputBorder()
              ),
            ),
            SizedBox(height: 7,),
            TextFormField(
              controller: desController,
              decoration: InputDecoration(
                  border: UnderlineInputBorder()
              ),
            ),
          ],
        ),
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
        title:  const Text('Warning',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: ListBody(
            children: const [Text('There is no change on data')],
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