import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:taskapp_hive_db/models/taskUser.dart';

import 'package:taskapp_hive_db/provider/hive_db_provider.dart';
import 'package:taskapp_hive_db/screens/auth_wrapper.dart';
import 'package:taskapp_hive_db/screens/home_page.dart';
import 'package:taskapp_hive_db/screens/taskDetailsScreen.dart';
import 'package:taskapp_hive_db/screens/taskForm.dart';
import 'package:taskapp_hive_db/screens/taskSelectionScreen.dart';
import 'package:taskapp_hive_db/services/auth.dart';
import 'package:taskapp_hive_db/services/firebase_DB.dart';

import 'models/taskTile.dart';


late Box taskListBox;
late Box taskOrderBox;
late Box counterBox;
late Box firebaseUidBox;

Future<void> main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  //initialize hive offline storage
  await Hive.initFlutter();
  Hive.registerAdapter(taskTileAdapter());

  //open boxes
  taskListBox = await Hive.openBox('taskList');
  taskOrderBox = await Hive.openBox('taskOrder');
  counterBox = await Hive.openBox('counter');
  firebaseUidBox = await Hive.openBox('firebase_uid');

  runApp(
      MultiProvider(
        providers: [

          StreamProvider<taskUser?>.value(
              value: AuthService().user, initialData: null
          ),
          //StreamProvider
          ListenableProvider<databaseProvider>(create: (context) =>
              databaseProvider(
                taskListBox: taskListBox,
                taskOrderBox: taskOrderBox,
                counterBox: counterBox,
                firebaseUidBox: firebaseUidBox,
              )
          ),

        ],
        child: const MyApp(),
      )
  );
}

final _router = GoRouter(
    initialLocation: '/',
    routes:[

      GoRoute(path:'/',
        builder: (context, state) => const auth_wrapper(),
      ),


      GoRoute(
        path:'/home',
        builder: (context, state) => MyHomePage(),
        routes: [
          GoRoute(
              path: "tasks/:taskId",
              name: "tasks",
              builder: (BuildContext context, GoRouterState state) {
                int id = int.parse(state.params['taskId']!);
                return taskDetailScreen(taskId: id);
              },

              routes: [
                GoRoute(
                    path: "taskSelection/blocker/:blockedTaskId",
                    name: "task selection blocker",
                    builder: (BuildContext context, GoRouterState state) {
                      int id = int.parse(state.params['blockedTaskId']!);
                      return taskSelectionScreen(relatedTaskId: id);
                    }
                ),

                GoRoute(
                    path: "taskSelection/hasParent/:parentId",
                    name: "task selection hasParent",
                    builder: (BuildContext context, GoRouterState state) {
                      int id = int.parse(state.params['parentId']!);
                      return taskSelectionScreen(relatedTaskId: id);
                    }
                ),
                GoRoute(
                    path: "taskSelection/minor/:minorId",
                    name: "task selection minor task",
                    builder: (BuildContext context, GoRouterState state) {
                      int id = int.parse(state.params['minorId']!);
                      return taskSelectionScreen(relatedTaskId: id);
                    }
                ),
                GoRoute(
                    path: "taskSelection/urgent/:urgentId",
                    name: "task selection urgent task",
                    builder: (BuildContext context, GoRouterState state) {
                      int id = int.parse(state.params['urgentId']!);
                      return taskSelectionScreen(relatedTaskId: id);
                    }
                ),

                GoRoute(
                    path: "taskSelection/misc/:miscId",
                    name: "task selection misc task",
                    builder: (BuildContext context, GoRouterState state) {
                      int id = int.parse(state.params['miscId']!);
                      return taskSelectionScreen(relatedTaskId: id);
                    }
                ),

              ]
          ),
        ],
      ),


      GoRoute(
        path:'/createTasks',
        builder: (context, state)=> TaskForm(),
      )
    ]
);

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'task app',
      routerConfig: _router,
    );
  }
}

