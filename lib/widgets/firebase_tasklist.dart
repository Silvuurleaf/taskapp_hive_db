import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/taskTile.dart';

class firebaseTaskList extends StatefulWidget {
  const firebaseTaskList({Key? key}) : super(key: key);

  @override
  State<firebaseTaskList> createState() => _firebaseTaskListState();
}

class _firebaseTaskListState extends State<firebaseTaskList> {

  @override
  Widget build(BuildContext context) {

    final firebaseTaskList = Provider.of<List<taskTile>>(context);
    print("Creating firebase task list below is FB data");

    print(firebaseTaskList);
    firebaseTaskList.forEach((task) {
      print(task.title);
    });

    //return a list view builder of all of the tasks from DB
    return Container();
  }
}
