import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/taskTile.dart';

class databaseProvider extends ChangeNotifier {

  //reference to DB boxes opened in main
  Box taskListBox;  //Hive.box('taskList');
  Box taskOrderBox;  //Hive.box('taskOrder');
  Box counterBox;  //Hive.box('counter');
  Box firebaseUidBox;

  databaseProvider({
    required this.taskListBox,
    required this.taskOrderBox,
    required this.counterBox,
    required this.firebaseUidBox,
  });

  List<taskTile> _taskList = [];
  int counter = 0;
  var _firebase_uid;

  void increment() {
    counter++;
    notifyListeners();
  }

  void decrement() {
    counter--;
    notifyListeners();
  }

  int getCount(){
    return counter;
  }


  //for first time use of app
  void createDefaultDB(){
    //add dummy data to referenced list
    _taskList.add(
        taskTile(
            title: 'Example',
            description: 'Content',
            status: 'Open',
            datetime: 'Time',
            id: counter.toString(),
            personal: true,
        ));

    //not notifying listeners yet
    counter++;
  }

  Future<void> loadData() async{

    _taskList = taskListBox.get(0).cast<taskTile>();
    counter = counterBox.get(0);

    //check if null? unsure if this breaks
    _firebase_uid = firebaseUidBox.get(0);

    notifyListeners();
  }

  Future<void> updateData() async{
    taskListBox.put(0,_taskList);
    counterBox.put(0,counter);
    //assume firebase uid does not change
    notifyListeners();
  }

  void changeTaskList(List<taskTile> taskList) {
    _taskList = taskList;
    //updateData();
  }

  List<taskTile> getTaskList(){
    return _taskList;
  }

  Future<void> setFirebaseUid(String uid) async {
    _firebase_uid = uid;
    firebaseUidBox.put(0, _firebase_uid);

    print("UPDATED FIREBASE UID");
    notifyListeners();

    //where to call this and do i need to call on after build in the authentication section?
  }

  String getFirebaseUid() {
    return _firebase_uid;
  }

}