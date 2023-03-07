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

    final firebase_snapshot = Provider.of<QuerySnapshot>(context);
    print("Creating firebase task list below is FB data");


/*    print("PRINTING THE DATA");
    if(firebase_snapshot != null){
      //var firebaseTaskList =
      firebase_snapshot.docs.map(
          (element){
            print(element.data());
          }
      );
    }*/

    return Container();
  }
}
