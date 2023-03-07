import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../models/taskTile.dart';
import '../provider/hive_db_provider.dart';
import '../widgets/task_image.dart';

class taskDetailScreen extends StatefulWidget {
  var taskId;
  var blocker_id;

  taskDetailScreen({
    Key? key,
    required this.taskId
  }) : super(key: key);

  @override
  State<taskDetailScreen> createState() => _taskDetailScreenState();
}

class _taskDetailScreenState extends State<taskDetailScreen> {

  final titleController = TextEditingController();
  String taskTitle = '';

  final descController = TextEditingController();
  String description ='';

  final statusController = TextEditingController();

  String? status = '';
  List<String> status_items = ['Open', 'In Progress', 'Completed'];
  String? selectedItem = 'Open';


  String datetime = '';

  var taskItems;
  var currentTask;
  var taskOrder;
  var numTasks;

  var taskDB;


  var imageFilePath;
  late final Function imageCallBackFunction;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    taskDB = Provider.of<databaseProvider>(context, listen: false);

    taskItems = taskDB.getTaskList();

    currentTask = taskItems[(widget.taskId)];

    var taskId = widget.taskId;

    titleController.text  = currentTask.title;
    descController.text = currentTask.description;

    print("current task id: $taskId");
    imageFilePath = currentTask.imagePath;
    print("current task imagePath: $imageFilePath");

  }

  //taskItems.getAtIndex(widget.taskId).title

  @override
  Widget build(BuildContext context) {

    getGalleryImage() async {
      ImagePicker image = ImagePicker();
      var img = await image.pickImage(source: ImageSource.gallery);
      setState(() {
        imageFilePath = File(img!.path).path;
      });
    }

    imageFilePath ??= "";

    int taskId = widget.taskId;
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

              task_image(imageFilePath: imageFilePath, callbackFunction:getGalleryImage),

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

                    //TODO logic to remove task item and update the order of the list

                    //taskTile oldTask = taskItems.getById(taskId.toString());
                    var findById = (taskTile) => taskTile.id == taskId.toString();
                    var result = taskItems.where(findById);
                    taskTile oldTask = result.isNotEmpty ? result.first : null;

                    bool? oldTask_personal = oldTask.personal;

                    taskTile newTask = taskTile(title:taskTitle,
                        description:description,
                        status:status,
                        datetime:formattedDate,
                        id:taskId.toString(),
                        personal: oldTask_personal,
                        imagePath: imageFilePath
                    );


                    //remove the task from the ordering
                    //taskOrder.removeWhere((item) => item.id == oldTask.id.toString());

                    //push the edited task to the front of the stack
                    //taskOrder.insert(0, newTask);
                    //taskOrder.pushItem(newTask);

                    taskItems[taskId].updateTask(
                        taskTitle,
                        description, status,
                        formattedDate, taskId.toString()
                    );

                    taskDB.changeTaskList(taskItems);
                    //taskDB.changeTaskOrderList(taskOrder);
                    await taskDB.updateData();

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
        SingleChildScrollView(
          child: ExpansionTile(
            leading: const Icon(Icons.block),
            title: const Text('Blocked By',
                key: ValueKey('blocked_byTab')
            ),
            children: [
              ElevatedButton(
                  key: const ValueKey('add_blocker_task'),
                  onPressed: (){
                    int currentTaskId = widget.taskId;
                    context.push('/tasks/$currentTaskId/taskSelection/blocker/$currentTaskId');
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

              Consumer<databaseProvider>(builder: (context, provider, listTile){
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
                                      setState(() {
                                        taskItems[widget.taskId].blockedBy.removeWhere((item) =>
                                        item.id == blockerTask.id.toString());

                                        taskDB.changeTaskList(taskItems);
                                      });

                                      await taskDB.updateData();

                                    }, icon: const Icon(Icons.delete))
                                  ],
                                ),

                                onTap: (){
                                  int currentTaskId = widget.taskId;
                                  String blockerTaskId = blockerTask.id.toString();
                                  context.push('/tasks/$blockerTaskId');
                                },
                              );
                          }
                      ),
                    ]
                );
              }),
            ],
          ),
        ),

        //has parent expansion tile
        SingleChildScrollView(
          child: ExpansionTile(
            leading: const Icon(Icons.filter),
            title: const Text('Subtask of'),
            children: [
              ElevatedButton(
                  key: const ValueKey('add_parent_task'),
                  onPressed: (){
                    int currentTaskId = widget.taskId;
                    context.push('/tasks/$currentTaskId/taskSelection/hasParent/$currentTaskId');
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
              Consumer<databaseProvider>(builder: (context, provider, listTile){
                return ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children:[
                      ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: currentTask.parentTasks.length,
                          itemBuilder: (_, index) {
                            final parentTask = currentTask.parentTasks[index];

                            return
                              ListTile(
                                title: Text(parentTask.title),
                                subtitle:
                                Column (
                                  children: <Widget> [
                                    IconButton(onPressed: () async {
                                      setState(() {
                                        taskItems[widget.taskId].parentTasks.removeWhere((item) =>
                                        item.id == parentTask.id.toString());

                                        taskDB.changeTaskList(taskItems);
                                      });

                                      await taskDB.updateData();

                                    }, icon: const Icon(Icons.delete))
                                  ],
                                ),

                                onTap: (){
                                  int currentTaskId = widget.taskId;
                                  String parentTaskId = parentTask.id.toString();
                                  context.push('/tasks/$parentTaskId');
                                },
                              );
                          }
                      ),
                    ]
                );
              }),
            ],
          ),
        ),

        //minor task expansion tile
        SingleChildScrollView(
          child: ExpansionTile(
            leading: const Icon(Icons.watch_later),
            title: const Text('Minor'),
            children: [
              ElevatedButton(
                  key: const ValueKey('add_minor_task'),
                  onPressed: (){
                    int currentTaskId = widget.taskId;
                    context.push('/tasks/$currentTaskId/taskSelection/minor/$currentTaskId');
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

              Consumer<databaseProvider>(builder: (context, provider, listTile){
                return ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children:[
                      ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: currentTask.minorTasks.length,
                          itemBuilder: (_, index) {
                            final minorTask = currentTask.minorTasks[index];

                            return
                              ListTile(
                                title: Text(minorTask.title),
                                subtitle:
                                Column (
                                  children: <Widget> [
                                    IconButton(onPressed: () async {
                                      setState(() {
                                        taskItems[widget.taskId].minorTasks.removeWhere((item) =>
                                        item.id == minorTask.id.toString());

                                        taskDB.changeTaskList(taskItems);
                                      });

                                      await taskDB.updateData();

                                    }, icon: const Icon(Icons.delete))
                                  ],
                                ),

                                onTap: (){
                                  int currentTaskId = widget.taskId;
                                  String minorTaskId = minorTask.id.toString();
                                  context.push('/tasks/$minorTaskId');
                                },
                              );
                          }
                      ),
                    ]
                );
              }),
            ],
          ),
        ),

        //urgent task expansion tile
        SingleChildScrollView(
          child: ExpansionTile(
            leading: const Icon(Icons.warning),
            title: const Text('Urgent'),
            children: [
              ElevatedButton(
                  key: const ValueKey('add_urgent_task'),
                  onPressed: (){
                    int currentTaskId = widget.taskId;
                    context.push('/tasks/$currentTaskId/taskSelection/urgent/$currentTaskId');
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

              Consumer<databaseProvider>(builder: (context, provider, listTile){
                return ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children:[
                      ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: currentTask.urgentTasks.length,
                          itemBuilder: (_, index) {
                            final urgentTask = currentTask.urgentTasks[index];

                            return
                              ListTile(
                                title: Text(urgentTask.title),
                                subtitle:
                                Column (
                                  children: <Widget> [
                                    IconButton(onPressed: () async {
                                      setState(() {
                                        taskItems[widget.taskId].urgentTasks.removeWhere((item) =>
                                        item.id == urgentTask.id.toString());

                                        taskDB.changeTaskList(taskItems);
                                      });

                                      await taskDB.updateData();

                                    }, icon: const Icon(Icons.delete))
                                  ],
                                ),

                                onTap: (){
                                  int currentTaskId = widget.taskId;
                                  String urgentTaskId = urgentTask.id.toString();
                                  context.push('/tasks/$urgentTaskId');
                                },
                              );
                          }
                      ),
                    ]
                );
              }),
            ],
          ),
        ),

        //misc task expansion tile
        SingleChildScrollView(
          child: ExpansionTile(
            leading: const Icon(Icons.miscellaneous_services),
            title: const Text('Misc'),
            children: [
              ElevatedButton(
                  key: const ValueKey('add_misc_task'),
                  onPressed: (){
                    int currentTaskId = widget.taskId;
                    context.push('/tasks/$currentTaskId/taskSelection/urgent/$currentTaskId');
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


              Consumer<databaseProvider>(builder: (context, provider, listTile){
                return ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children:[
                      ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: currentTask.miscTasks.length,
                          itemBuilder: (_, index) {
                            final miscTask = currentTask.miscTasks[index];

                            return
                              ListTile(
                                title: Text(miscTask.title),
                                subtitle:
                                Column (
                                  children: <Widget> [
                                    IconButton(onPressed: () async {
                                      setState(() {
                                        taskItems[widget.taskId].miscTasks.removeWhere((item) =>
                                        item.id == miscTask.id.toString());

                                        taskDB.changeTaskList(taskItems);
                                      });

                                      await taskDB.updateData();

                                    }, icon: const Icon(Icons.delete))
                                  ],
                                ),

                                onTap: (){
                                  int currentTaskId = widget.taskId;
                                  String blockerTaskId = miscTask.id.toString();
                                  context.push('/tasks/$blockerTaskId');
                                },
                              );
                          }
                      ),
                    ]
                );
              }),
            ],
          ),
        ),

      ]
  );




}
