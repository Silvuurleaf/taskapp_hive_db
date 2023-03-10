import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskapp_hive_db/models/taskUser.dart';
import 'package:uuid/uuid.dart';
import '../models/taskTile.dart';

class FB_databaseService{

  var uuid = const Uuid();

  FB_databaseService();

  final CollectionReference taskCollection = FirebaseFirestore.instance.collection('tasks');

  Future addTaskData(taskTile taskObject) async {

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


    return await taskCollection.add({
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


/*    return await taskCollection.doc(id).set({
      'taskId': id,
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
    });*/

  }
  Future updateTask(taskTile taskObject) async {

    return await taskCollection.doc(taskObject.id).set({
      'taskId': taskObject.id,
      'title': taskObject.title,
      'description':taskObject.description,
      'status': taskObject.status,
      'images': taskObject.imagePath,
      'shared': true,
      'blockerTasks': taskObject.blockedBy ?? [],
      'parentTasks':taskObject.parentTasks ?? [],
      'minorTasks': taskObject.minorTasks ?? [],
      'urgentTasks': taskObject.urgentTasks ?? [],
      'miscTasks': taskObject.miscTasks ?? [],
    });

  }

  Future<taskTile?> getTaskByDocId(String docId) async {
    var snapshot = await taskCollection.get();

    var data = _tasksFromSnapshot(snapshot);
    for (var tile in data) {
      if(tile.id == docId){
        return tile;
      }
    }
    return null;

  }


  Future<List<taskTile>>? firebaseSnapshot() async {
    var snapshot = await taskCollection.get();
    var data = _tasksFromSnapshot(snapshot);
    //data.forEach((taskTile tile) => print(tile.title));

    return data;
  }


  List<taskTile> _tasksFromSnapshot(QuerySnapshot snapshot){
    return snapshot.docs.map((doc) {
      return taskTile(
          title: doc.data().toString().contains('title') ? doc.get('title') : '',
          description: doc.data().toString().contains('description') ? doc.get('description') : '',
          status: doc.data().toString().contains('status') ? doc.get('status') : '',
          datetime: doc.data().toString().contains('datetime') ? doc.get('datetime') : '',
          id: doc.id.toString(),
          personal: false,
      );
    }).toList();
  }

  Future<void> deleteTask(String taskId) async {
    print("deleting task");
    taskCollection.doc(taskId).delete();
  }
}