import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/taskTile.dart';
import '../provider/hive_db_provider.dart';
import '../services/firebase_DB.dart';
import '../widgets/task_image.dart';
import '../widgets/toggle_button.dart';

class TaskForm extends StatefulWidget {

  var taskId;

  TaskForm({
    Key? key,
    this.taskId,
  }) : super(key: key);

  @override
  State<TaskForm> createState() => _TaskForm();
}

class _TaskForm extends State<TaskForm> {
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
  var numTasks;

  var taskDB;


  //TODO initialize file object with some value
  var imageFilePath = '';
  late final Function imageCallBackFunction;

  bool personal = true;
  late final Function saveLocationCallBackFunction;

  late final firebaseDB;

  @override
  void initState() {
    super.initState();

    //maybe be able to deprecate other provider
    taskDB = Provider.of<databaseProvider>(context, listen: false);
    taskItems = taskDB.getTaskList();

    firebaseDB = FB_databaseService();

    titleController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context){

    getGalleryImage() async {
      ImagePicker image = ImagePicker();
      var img = await image.pickImage(source: ImageSource.gallery);
      setState(() {
        imageFilePath = File(img!.path).path;
      });
    }

    getSaveLocation(bool isPersonal) {
      setState(() {
        personal = isPersonal;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Creation'),
      ),
      body: Center(
          child: ListView(
            children: [
              const SizedBox(height: 24),
              buildTitle(),
              const SizedBox(height: 24),
              task_image(imageFilePath: imageFilePath, callbackFunction: getGalleryImage,),
              const SizedBox( height: 12),
              buildDesc(),
              const SizedBox(height: 24),

              //status dropdown
              SizedBox(
                width: 120,
                child:statusDropDown(),
              ),

              const SizedBox(height: 120),
              buildDateTime(),
              const SizedBox(height: 24),

              //toggle button submission
              ToggleButton(callbackFunction: getSaveLocation,),
              const SizedBox(height: 24),
              //submit task button
              ElevatedButton(
                  key: const ValueKey('submit_task'),
                  onPressed: () async {
                    taskTitle = titleController.text;
                    description = descController.text;

                    DateTime now = DateTime.now();
                    String formattedDate = DateFormat('kk:mm:ss \n EEE d MMM').format(now);

                    String taskId = taskDB.getCount().toString();

                    print("THE COUNT OF TASK ITEMS IN LOCAL: $taskId");


                    taskTile newTask;

                    if(personal){
                      if(imageFilePath == null || imageFilePath == ""){
                        print("image not detected");
                        newTask = taskTile(
                          title:taskTitle,
                          description:description,
                          status:status,
                          datetime:formattedDate,
                          id:taskId,
                          personal: personal,
                        );
                      }
                      else{

                        print("image detected");
                        newTask = taskTile(
                            title:taskTitle,
                            description:description,
                            status:status,
                            datetime:formattedDate,
                            id:taskId,
                            personal: personal,
                            imagePath: imageFilePath);
                      }

                      taskItems.add(newTask);
                      //update task counter

                      var ct = taskDB.getCount();
                      print("CURRENT TASK COUNTER: $ct");

                      taskDB.increment();
                      taskDB.changeTaskList(taskItems);
                      await taskDB.updateData();

                    }else{
                      //shared task

                      newTask = taskTile(
                          title:taskTitle,
                          description:description,
                          status:status,
                          datetime:formattedDate,
                          id:taskId,
                          personal: personal,
                          imagePath: imageFilePath);

                      await firebaseDB.addTaskData(newTask);
                    }


                    //test if data was updated here?
                    context.push('/');

                  },
                  child: const Text('Submit')

              )
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

    onSubmitted: (value) => setState(() {
      this.taskTitle = value;
    }),

    key: const Key('task_title'),

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

    onSubmitted: (value) => setState(() {
      this.description = value;
    }),

    key: const Key('task_description'),

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

  Widget buildDateTime() => SizedBox(
    height: 18,
    width: 128,
    child:Text(
      'last updated: $datetime',
      style: const TextStyle(fontSize: 14),
    ) ,
  );

}
