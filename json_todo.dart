import 'package:json_todo/json_todo.dart' as json_todo;
import 'dart:io';
import 'dart:convert';

Map<String?, String?> createNote(){
  
  Map<String?, String?> note = {};

  stdout.write("Name of the note:");
  String? Name = stdin.readLineSync();

  stdout.write("Note:");
  String? Note = stdin.readLineSync();

  note = {Name: Note };

  return note;
}


class NoteManager {


  File file;


  NoteManager(this.file);


  Future<void> printNotes() async {


    try {

     await printNoteList();
      
    } on PathNotFoundException {

      print("No Notes to Display :)");

    } on TypeError{
      _printOneNote();
    }


  }

  Future<void> addNote(Map<String?, String?> note) async {

    String contents;

    try {

      contents = await file.readAsString();
      
      List<Map<String?, String?>> notes = (jsonDecode(contents) as List)
        .map((e) => Map<String?, String?>.from(e))
        .toList();
      
      if(notes.length >= 2){
        await _addNoteToExistingList(note);
      }
    
    } on PathNotFoundException {
      await _addNoteToNewList(note);
    } on FormatException {
      await _addNoteToNewList(note);
    } on TypeError{
      await _addSecondNoteToExistingList(note);
    }

  } 


  Future<void> _addNoteToNewList(Map<String?, String?> note) async {
    await file.writeAsString(jsonEncode(note));
  }

  Future<void> _addSecondNoteToExistingList(Map<String?, String?> noteOne) async {

    String contents;
    
    contents = await file.readAsString();

    Map<String?, String?> noteTwo = Map<String?, String?>.from(jsonDecode(contents));

    List<Map<String?, String?>> notesList = [noteOne, noteTwo];

    await file.writeAsString(jsonEncode(notesList));
  }

  Future<void> _addNoteToExistingList(Map<String?, String?> note) async {

    String contents;
    
    contents = await file.readAsString();
    
    List<Map<String?, String?>> notes = (jsonDecode(contents) as List)
        .map((e) => Map<String?, String?>.from(e))
        .toList();

    notes.add(note);

    await file.writeAsString(jsonEncode(notes));
  }


  Future<void> printNoteList() async {

    String contents = await file.readAsString();
    
    List<Map<String?, String?>> notes =
        (jsonDecode(contents) as List)
            .map((e) => Map<String?, String?>.from(e))
            .toList();

   
    print(notes);

  }

  Future<void> _printOneNote() async {

    String contents = await file.readAsString();
    
    Map<String?, String?> note = Map<String?, String?>.from(jsonDecode(contents));

    print(note);

  }

}


void main(List<String> arguments) async {

  Map<String?, String?> note = {};
  
  final File file = File("data.json");


  while (true) {

    print("1. Add New Note");
    print("2. View Current Notes");

    String? answer = stdin.readLineSync();

    NoteManager nm = NoteManager(file);


    if (answer == "1"){
     
      note = createNote();

      await nm.addNote(note);


    }else if (answer == "2"){

      await nm.printNotes();

    }else{ 
      stdout.writeln("Please pick a valid number");
    }

  }
}
