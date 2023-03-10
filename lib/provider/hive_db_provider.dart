import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/taskTile.dart';

class databaseProvider extends ChangeNotifier {

  //reference to DB boxes opened in main
  Box taskListBox;  //Hive.box('taskList');
  Box taskOrderBox;  //Hive.box('taskOrder');
  Box counterBox;  //Hive.box('counter');

  databaseProvider({
    required this.taskListBox,
    required this.taskOrderBox,
    required this.counterBox,
  });

  List<taskTile> _taskList = [];
  int counter = 0;
  late String uid;

  void resetCount(){
    counter  = 0;
  }

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


  Future<void> loadData() async{

    _taskList = taskListBox.get(0).cast<taskTile>();
    counter = counterBox.get(0);

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


  void setFirebaseUid(String response_uid){
    uid = response_uid;
  }

}