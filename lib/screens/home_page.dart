import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:taskapp_hive_db/services/auth.dart';
import '../provider/hive_db_provider.dart';
import '../services/firebase_DB.dart';
import '../widgets/firebase_tasklist.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final AuthService _authService = AuthService();

  TextEditingController _controller = TextEditingController();

  var taskDB;
  var task_counter;
  var taskItems;

  String? status = '';
  List<String> status_items = ['All', 'Open', 'In Progress', 'Completed'];
  String? selectedItem = 'All';


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _onAfterBuild(context));
    _controller = TextEditingController();

  }

  void _onAfterBuild(BuildContext context) {
    taskDB = Provider.of<databaseProvider>(context, listen: false);

    try{
      taskDB.loadData();
    }
    catch (e){
      print(e.toString());
    }

    //reference to stored tasks in database
    taskItems = taskDB.getTaskList();
    //reference to number of tasks
    task_counter = taskDB.getCount();


  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
            title: const Text('Tasks'),
            actions: <Widget>[
                IconButton(onPressed: () async{
                  await _authService.signOut();
                },
                  icon: const Icon(Icons.logout_outlined),
              )

            ],

        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.push('/createTasks');
          },
          key: const Key("addTaskButton"),
          child: const Icon(
            Icons.add_circle,
            size: 50.0,
          ),
        ),


        body: StreamProvider<QuerySnapshot?>.value(
          value: FB_databaseService().tasksFromFirebase,
          initialData: null,
          child: Column(
            children: [

              Consumer<databaseProvider>(builder: (context, provider, listTile) {
                if (taskItems == null){
                  return  const SizedBox(
                    width: 200.0,
                    height: 300.0,
                  );
                }
                else {
                  return Expanded(
                    child: ListView.builder(
                      key: const Key('task_list'),
                      itemCount: taskItems.length,
                      itemBuilder: buildList,
                    ),
                  );
                }
              }),

              firebaseTaskList(),

              //Combine the fb database objects with locally stored objects

            ],
          ),
        )
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
        child:
        Visibility(
            visible: true,
            child: Dismissible(
              key: Key(taskItems[index].id.toString()),
              background: trashBackground(),
              onDismissed: (direction){

                var orderLength = taskItems.length;

                print("Length of task order: $orderLength");
                print('task order: $taskItems');
                print('index is $index');
                String ID = taskItems[index].id.toString();
                print('id is $ID');

                //taskOrder.removeWhere((item) => item.id == taskOrder[index].id.toString());
                taskItems.removeWhere((item) => item.id == taskItems[index].id.toString());
                taskDB.decrement();

                taskDB.changeTaskList(taskItems);
                taskDB.updateData();

              },
              child:Visibility(
                visible: true,
                child: InkWell(
                  onTap: () {

                    //TODO index is based on index of taskOrder_provider. Need indx to be task ID

                    //TODO push based on their taskId, not index what will this break

                    String clickedTaskTileId = taskItems[index].id.toString();

                    //on click edit/opening detail view
                    context.push('/tasks/$clickedTaskTileId');

                  },
                  child:ListTile(
                    title: Text(taskItems[index].title),
                    subtitle: Text('$index'),
                  ),
                ),
              ),
            )
        )
    );
  }

  Widget rowItem(context, index) {
    return Dismissible(
      key: Key(taskItems[index].id.toString()),
      background: trashBackground(),
      onDismissed: (direction){

        var orderLength = taskItems.length;

        print("Length of task order: $orderLength");
        print('task order: $taskItems');
        print('index is $index');
        String ID = taskItems[index].id.toString();
        print('id is $ID');

        //taskOrder.removeWhere((item) => item.id == taskOrder[index].id.toString());
        taskItems.removeWhere((item) => item.id == taskItems[index].id.toString());
        taskDB.decrement();

        taskDB.changeTaskList(taskItems);
        taskDB.updateData();

      },
      child:Visibility(
        visible: true,
        child: InkWell(
          onTap: () {

            //TODO index is based on index of taskOrder_provider. Need indx to be task ID

            //TODO push based on their taskId, not index what will this break

            String clickedTaskTileId = taskItems[index].id.toString();

            //on click edit/opening detail view
            context.push('/tasks/$clickedTaskTileId');

          },
          child:ListTile(
            title: Text(taskItems[index].title),
            subtitle: Text('$index'),
          ),
        ),
      ),
    );
  }

  Widget trashBackground(){
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20),
      color: Colors.red,
      child: Icon(Icons.delete, color: Colors.white,),
    );
  }

  Widget statusFilter() => DropdownButtonFormField<String>(

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

}
