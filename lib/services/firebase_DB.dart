import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

import 'package:taskapp_hive_db/models/taskUser.dart';

import '../models/taskTile.dart';

class FB_databaseService{

  final String? uid;
  FB_databaseService({this.uid});

  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  Future<void> configureUser() async {
    //builds a document w/ uid
    //userCollection.doc(uid);

    //in document user has a subcollection of tasks
    CollectionReference userTasks = userCollection.doc(uid).collection('user_tasks');
    //every new task will be a new document within user_tasks subcollection
    //using the taskId
  }

  Future updateTaskData(String uid, taskTile taskObject) async {

    //opening User collections and creating a new doc w/ uid
    //new doc will have a sub collection of user tasks
    //a new doc is added to subcollection containing taskObject data


    //configure new list objects for taskObject instead of using taskTile object
    //lists are stored as lists of taskIds

    List<String?> blockerTask_ids = [];
    List<String?> parentTasks_ids = [];
    List<String?> minorTasks_ids = [];
    List<String?> urgentTasks_ids = [];
    List<String?> miscTasks_ids = [];

    for(var task in taskObject.blockedBy){
      blockerTask_ids.add(task.id);
    }

    for(var task in taskObject.parentTasks){
      parentTasks_ids.add(task.id);
    }

    for(var task in taskObject.minorTasks){
      minorTasks_ids.add(task.id);
    }

    for(var task in taskObject.urgentTasks){
      urgentTasks_ids.add(task.id);
    }
    for(var task in taskObject.miscTasks){
      miscTasks_ids.add(task.id);
    }


    return await userCollection.doc(uid).collection('user_tasks').doc(taskObject.id).set({
      'userId': uid,
      'taskId': taskObject.id,
      'title': taskObject.title,
      'description':taskObject.description,
      'status': taskObject.status,
      'images': taskObject.imagePath,
      'shared': true,
      'blockerTasks': blockerTask_ids,
      'parentTasks':parentTasks_ids,
      'minorTasks': minorTasks_ids,
      'urgentTasks': urgentTasks_ids,
      'miscTasks': miscTasks_ids,
    });

  }

   Stream<QuerySnapshot> get tasksFromFirebase {
    //'_MapStream<QuerySnapshotPlatform, QuerySnapshot<Map<String, dynamic>>>'
    var snapshots = userCollection.doc(uid).collection('user_tasks').snapshots();

    return snapshots;
  }

}