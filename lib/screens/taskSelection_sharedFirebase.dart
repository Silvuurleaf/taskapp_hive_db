import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/taskTile.dart';
import '../provider/hive_db_provider.dart';
import '../services/firebase_DB.dart';


class taskSelectionScreenShared extends StatefulWidget {
  var headTaskId;

  taskSelectionScreenShared({
    Key? key,
    required this.headTaskId
  }) : super(key: key);

  @override
  State<taskSelectionScreenShared> createState() => _taskSelectionScreenSharedState();
}

class _taskSelectionScreenSharedState extends State<taskSelectionScreenShared> {
  var taskId;
  var taskItems;
  var taskDB;
  var firebaseDB;


  @override
  void initState() {
    super.initState();

    firebaseDB = FB_databaseService();

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
        appBar: AppBar(),
        body: Column(
            children: [
              FutureBuilder(
                future: firebaseDB.firebaseSnapshot(),
                builder: (context, AsyncSnapshot<List<taskTile>> snapshot){
                  if(snapshot.hasData) {
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return const Center(child: CircularProgressIndicator());
                    }
                    else{
                      return ListView.builder(
                          shrinkWrap: true,
                          key: const Key('task_list_firebase'),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, idx) {
                            return SizedBox(
                              child: InkWell(
                                onTap: () {
                                  var Currroute = ModalRoute.of(context)?.settings.name;


                                  taskTile relatedTask = snapshot.data![idx];
                                  addToRelatedGroup(relatedTask);

                                  context.pop();
                               },
                                child: ListTile(
                                  title: Text(snapshot.data![idx].title ?? ''),
                                  subtitle: Text('$idx'),
                                ),
                              ),
                            );

                          });
                    }
                  }
                  else if (snapshot.hasError){
                    return const Text("error occurred");
                  }
                  else {
                    return const Center(child: CircularProgressIndicator());
                  }
              })
            ],
          ),
        );
  }

  Widget buildList(BuildContext context, int index) {
    return Container(
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.blue,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10)),

      child: InkWell(
        onTap: () {

          taskTile relatedTask = taskItems[index];

          addToRelatedGroup(relatedTask);

          //taskItems.getAtIndex(widget.relatedTaskId).blockedBy.add(relatedTask);

          context.pop();

        },
        child:ListTile(
          title: Text(taskItems[index].title),
        ),
      ),

    );
  }


  Future<void> addToRelatedGroup(taskTile relatedTask) async {
    var routeLocation = GoRouter.of(context).location;

    print("ROUTE LOCATION: $routeLocation");

    RegExp blocker = RegExp('\/sharedTasks\/.*\/sharedTaskSelection/blocker/.*');
    RegExp hasParent = RegExp('\/sharedTasks\/.*\/sharedTaskSelection/hasParent/.*');
    RegExp urgent = RegExp('\/sharedTasks\/.*\/sharedTaskSelection/urgent/.*');
    RegExp minor = RegExp('\/sharedTasks\/.*\/sharedTaskSelection/minor/.*');
    RegExp misc = RegExp('\/sharedTasks\/.*\/sharedTaskSelection/misc/.*');


    //get the task tile for current task and check its subsequent lists and add the related task
    if (blocker.hasMatch(routeLocation)){

      var task = await firebaseDB.getTaskByDocId(widget.headTaskId);
      task.blockedBy.add(relatedTask);

      await firebaseDB.updateTask(task);

    }
    else if(hasParent.hasMatch(routeLocation)){
      taskItems[widget.headTaskId].parentTasks.add(relatedTask);
      taskDB.changeTaskList(taskItems);
      await taskDB.updateData();
    }
    else if(urgent.hasMatch(routeLocation)){
      taskItems[widget.headTaskId].urgentTasks.add(relatedTask);
      taskDB.changeTaskList(taskItems);
      await taskDB.updateData();
    }
    else if(minor.hasMatch(routeLocation)){
      taskItems[widget.headTaskId].minorTasks.add(relatedTask);
      taskDB.changeTaskList(taskItems);
      await taskDB.updateData();
    }
    else if(misc.hasMatch(routeLocation)){
      taskItems[widget.headTaskId].miscTasks.add(relatedTask);
      taskDB.changeTaskList(taskItems);
      await taskDB.updateData();
    }

  }
}



