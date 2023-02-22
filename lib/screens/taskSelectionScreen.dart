import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/taskTile.dart';
import '../provider/hive_db_provider.dart';


class taskSelectionScreen extends StatefulWidget {
  var relatedTaskId;

  taskSelectionScreen({
    Key? key,
    required this.relatedTaskId
  }) : super(key: key);

  @override
  State<taskSelectionScreen> createState() => _taskSelectionScreenState();
}

class _taskSelectionScreenState extends State<taskSelectionScreen> {
  var taskId;
  var taskItems;
  var taskDB;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    taskDB = Provider.of<databaseProvider>(context, listen: false);
    taskItems = taskDB.getTaskList();
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
        body: Container(
          child: Column(
            children: [

              Consumer<databaseProvider>(builder: (context, provider, listTile) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: taskItems.length,
                    itemBuilder: buildList,
                  ),
                );
              }),
            ],
          ),
        ));
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

    RegExp blocker = RegExp('\/tasks\/([0-9]|[1-9][0-9]|[1-9][0-9][0-9])\/taskSelection/blocker/([0-9]|[1-9][0-9]|[1-9][0-9][0-9])');
    RegExp hasParent = RegExp('\/tasks\/([0-9]|[1-9][0-9]|[1-9][0-9][0-9])\/taskSelection/hasParent/([0-9]|[1-9][0-9]|[1-9][0-9][0-9])');
    RegExp urgent = RegExp('\/tasks\/([0-9]|[1-9][0-9]|[1-9][0-9][0-9])\/taskSelection/urgent/([0-9]|[1-9][0-9]|[1-9][0-9][0-9])');
    RegExp minor = RegExp('\/tasks\/([0-9]|[1-9][0-9]|[1-9][0-9][0-9])\/taskSelection/minor/([0-9]|[1-9][0-9]|[1-9][0-9][0-9])');
    RegExp misc = RegExp('\/tasks\/([0-9]|[1-9][0-9]|[1-9][0-9][0-9])\/taskSelection/misc/([0-9]|[1-9][0-9]|[1-9][0-9][0-9])');


    //get the task tile for current task and check its subsequent lists and add the related task
    if (blocker.hasMatch(routeLocation)){
      taskItems[widget.relatedTaskId].blockedBy.add(relatedTask);

      taskDB.changeTaskList(taskItems);
      await taskDB.updateData();


    }
    else if(hasParent.hasMatch(routeLocation)){
      taskItems[widget.relatedTaskId].parentTasks.add(relatedTask);
      taskDB.changeTaskList(taskItems);
      await taskDB.updateData();
    }
    else if(urgent.hasMatch(routeLocation)){
      taskItems[widget.relatedTaskId].urgentTasks.add(relatedTask);
      taskDB.changeTaskList(taskItems);
      await taskDB.updateData();
    }
    else if(minor.hasMatch(routeLocation)){
      taskItems[widget.relatedTaskId].minorTasks.add(relatedTask);
      taskDB.changeTaskList(taskItems);
      await taskDB.updateData();
    }
    else if(misc.hasMatch(routeLocation)){
      taskItems[widget.relatedTaskId].miscTasks.add(relatedTask);
      taskDB.changeTaskList(taskItems);
      await taskDB.updateData();
    }

  }
}



