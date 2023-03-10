import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../models/taskTile.dart';
import '../provider/hive_db_provider.dart';
import '../services/firebase_DB.dart';
import '../widgets/task_image.dart';

class taskDetails_firebase extends StatefulWidget {
  String taskId;
  var blocker_id;

  taskDetails_firebase({
    Key? key,
    required this.taskId
  }) : super(key: key);

  @override
  State<taskDetails_firebase> createState() => _taskDetails_firebaseState();
}

class _taskDetails_firebaseState extends State<taskDetails_firebase> {

  final titleController = TextEditingController();
  String taskTitle = '';

  final descController = TextEditingController();
  String description ='';

  final statusController = TextEditingController();

  String? status = '';
  List<String> status_items = ['Open', 'In Progress', 'Completed'];
  String? selectedItem = 'Open';


  String datetime = '';

  var currentTask;
  var numTasks;

  var taskDB;

  var firebaseDB;
  var firebaseTasks;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    firebaseDB = FB_databaseService();

    WidgetsBinding.instance.addPostFrameCallback((_) => _onAfterBuild(context));

  }

  void _onAfterBuild(BuildContext context) async{
    taskDB = Provider.of<databaseProvider>(context, listen: false);

    try{
      taskDB.loadData();
    }
    catch (e){
      print(e.toString());
    }

    firebaseTasks = await firebaseDB.firebaseSnapshot();

    currentTask = await firebaseDB.getTaskByDocId(widget.taskId);

    titleController.text  = currentTask.title;
    descController.text = currentTask.description;

    //firebaseTasks.forEach((taskTile task) => print(task));

  }

  //taskItems.getAtIndex(widget.taskId).title

  @override
  Widget build(BuildContext context) {

    String taskId = widget.taskId;
    //currentTask = firebaseTasks?.getTaskByDocId(widget.taskId);
    //String taskTitle = widge

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Task: Task$taskId'),
      ),
      drawer: buildNavDrawer(),
      body: Center(
          child: ListView(
            children: [
              const SizedBox(height: 24),
              buildTitle(),
              const SizedBox(height:12),

              const SizedBox(height: 24),
              buildDesc(),
              const SizedBox(height: 24),
              SizedBox(
                width: 120,
                child:statusDropDown(),
              ),

              const SizedBox(height: 120),
              buildDateTime(),
              const SizedBox(height: 24),

              //add an image

              //edit submission button
              ElevatedButton(
                  key: const ValueKey('edit_submit'),
                  onPressed: () async {
                    taskTitle = titleController.text;
                    description = descController.text;

                    //Map<String, String?> task_info = {'title': taskTitle, 'description': description, 'status': status};
                    DateTime now = DateTime.now();
                    String formattedDate = DateFormat('kk:mm:ss \n EEE d MMM').format(now);

                    currentTask.title = taskTitle;
                    currentTask.description = description;
                    currentTask.status = status;
                    currentTask.datetime = formattedDate;
                    currentTask.id = taskId;
                    currentTask.personal = false;
                    currentTask.imagePath = "";

                    await firebaseDB.updateTask(currentTask);

                    context.push('/');

                  },
                  child: const Text('Submit')

              ),


            ],
          )
      ),
    );
  }

  Widget statusDropDown() => DropdownButtonFormField<String>(

    decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 3, color: Colors.blue),
        )
    ),

    value: selectedItem,
    items: status_items.map((item) => DropdownMenuItem<String>(
        value: item,
        child: Text(item, style: const TextStyle(fontSize: 14),)
    )).toList(),

    onChanged: (item) => setState(() => {
      selectedItem = item,
      status = item,
    }),
    iconSize: 14,
    hint: const Text('task status'),
  );

  Widget buildTitle() => TextField(

    key: const Key('edit_task_title'),

    onSubmitted: (value) => setState(() {
      this.taskTitle = value;
    }),

    controller: titleController,
    decoration: InputDecoration(
      labelText: 'Title',
      hintText: 'Task1',
      border: const OutlineInputBorder(),

      suffixIcon: titleController.text.isEmpty
          ? Container(width: 0)
          : IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => titleController.clear(),
      ),
    ),
    keyboardType: TextInputType.text,
    textInputAction: TextInputAction.done,
  );


  Widget buildDesc() => TextField(

    key: const Key('edit_description'),
    onSubmitted: (value) => setState(() {
      this.description = value;
    }),

    controller: descController,
    decoration: InputDecoration(
      labelText: 'Description',
      hintText: 'Enter task description',
      border: const OutlineInputBorder(),

      suffixIcon: descController.text.isEmpty
          ? Container(width: 0)
          : IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => descController.clear(),
      ),
    ),

    style: const TextStyle(fontSize: 14),
    maxLines: 15,
    minLines: 7,

    keyboardType: TextInputType.text,
    textInputAction: TextInputAction.done,
  );

  //TODO need to add the time after creation, need an initial value
  Widget buildDateTime() => SizedBox(
    height: 18,
    width: 128,
    child:Text(
      'last updated: ' + datetime,
      style: const TextStyle(fontSize: 14),
    ) ,
  );


  //TODO move this widget to another file?
  Widget buildNavDrawer() => Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children:<Widget> [
          buildHeader(context),
          buildMenuItems(context),
        ],
      )
  );

  Widget buildHeader(BuildContext context) => Container(
      padding: EdgeInsets.only(
        top:MediaQuery.of(context).padding.top,
      )
  );


  Widget buildMenuItems(BuildContext context) => Column(
      children: [

        ListTile(
          leading: const Icon(Icons.home_outlined),
          title: const Text('Home'),
          onTap: (){
            context.push('/');
          },
        ),

        ListTile(
          leading: const Icon(Icons.arrow_back),
          title: const Text('Back'),
          onTap: (){
            context.pop();
            context.pop();
          },
        ),


        //TODO refactor so each expansion tile isn't so copy paste

        //TODO I think I need to change the lists being referenced. They all use blockedby list

        //blocker expansion tile
        Center(
          child: SingleChildScrollView(
            child: ExpansionTile(
              leading: const Icon(Icons.block),
              title: const Text('Blocked By',
                  key: ValueKey('blocked_byTab')
              ),
              children: [
                ElevatedButton(
                    key: const ValueKey('add_blocker_task'),
                    onPressed: (){
                      String currentTaskId = widget.taskId;



                      context.push('/sharedTasks/$currentTaskId/sharedTaskSelection/blocker/$currentTaskId');
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: const <Widget>[
                        Text('Add Task',
                            style: TextStyle(fontSize: 14,)
                        ),
                      ],
                    )
                ),

                FutureBuilder(
                    future: firebaseDB.firebaseSnapshot(),
                    builder: (context, AsyncSnapshot<List<taskTile>> snapshot){
                      if(snapshot.hasData) {
                        if(snapshot.connectionState == ConnectionState.waiting){
                          return const Center(child: CircularProgressIndicator());
                        }
                        else{
                          return ListView(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              children:[
                                ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    itemCount: currentTask.blockedBy.length,
                                    itemBuilder: (_, index) {
                                      final blockerTask = currentTask.blockedBy[index];

                                      return
                                        ListTile(
                                          title: Text(blockerTask.title),
                                          subtitle:
                                          Column (
                                            children: <Widget> [
                                              IconButton(onPressed: () async {
                                                setState(() async {
                                                  currentTask.blockedBy.removeWhere((item) =>
                                                  item.id == blockerTask.id.toString());

                                                  await firebaseDB.updateTask(currentTask);

                                                });

                                              }, icon: const Icon(Icons.delete))
                                            ],
                                          ),

                                          onTap: (){
                                            String blockerTaskId = blockerTask.id.toString();
                                            context.push('/tasks/$blockerTaskId');
                                          },
                                        );
                                    }
                                ),
                              ]
                          );
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
          ),
        ),

      ]
  );




}
