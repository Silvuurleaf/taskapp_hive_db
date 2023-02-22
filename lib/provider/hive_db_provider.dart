import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/taskTile.dart';

class databaseProvider extends ChangeNotifier {

  //reference to DB boxes opened in main
  final taskListBox = Hive.box('taskList');
  final taskOrderBox = Hive.box('taskOrder');
  final counterBox = Hive.box('counter');

  List<taskTile> _taskList = [];

  int counter = 0;

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
    _taskList.add(taskTile(title: 'Example', description: 'Content', status: 'Open', datetime: 'Time', id: counter.toString()));

    //not notifying listeners yet
    counter++;

  }

  Future<void> loadData() async{

    _taskList = taskListBox.get(0).cast<taskTile>();
    counter = counterBox.get(0);
    notifyListeners();
  }

  Future<void> updateData() async{
    taskListBox.put(0,_taskList);
    counterBox.put(0,counter);
    notifyListeners();
  }

  void changeTaskList(List<taskTile> taskList) {
    _taskList = taskList;
    //updateData();
  }

  List<taskTile> getTaskList(){
    return _taskList;
  }

}