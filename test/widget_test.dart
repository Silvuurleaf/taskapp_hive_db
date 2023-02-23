// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';


import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:taskapp_hive_db/main.dart';

import 'package:taskapp_hive_db/models/taskTile.dart';
import 'package:taskapp_hive_db/provider/hive_db_provider.dart';
import 'package:taskapp_hive_db/screens/home_page.dart';
import 'package:taskapp_hive_db/screens/taskDetailsScreen.dart';
import 'package:taskapp_hive_db/screens/taskForm.dart';

import 'widget_test.mocks.dart';

@GenerateMocks(
  [HiveInterface, Box],
  customMocks: [
    MockSpec<NavigatorObserver>(
      returnNullOnMissingStub: true,
    ),
    MockSpec<databaseProvider>(),
  ],
)



void main() async {

  MockHiveInterface mockHiveInterface = MockHiveInterface();
  MockBox mockHiveBox = MockBox();

  when(mockHiveInterface.openBox('taskList')).thenAnswer((_) async => mockHiveBox);
  when(mockHiveInterface.openBox('taskOrder')).thenAnswer((_) async => mockHiveBox);
  when(mockHiveInterface.openBox('counter')).thenAnswer((_) async => mockHiveBox);


  Box taskListBox = await mockHiveInterface.openBox('taskList');
  Box taskOrderBox = await mockHiveInterface.openBox('taskOrder');
  Box counterBox = await mockHiveInterface.openBox('counter');

  MockdatabaseProvider mockDBprovider = MockdatabaseProvider(
      taskListBox: taskListBox,
      taskOrderBox: taskOrderBox,
      counterBox: counterBox
  );



  List<taskTile> taskList = [];

  when(mockDBprovider.getTaskList()).thenReturn(taskList);
  when(mockDBprovider.getCount()).thenReturn(0);


  testWidgets("go to create task page", (WidgetTester tester) async {


    final observerMock = MockNavigatorObserver();

    final _router = GoRouter(
        initialLocation: '/',
        routes:[
          GoRoute(
            path:'/',
            builder: (context, state) => MyHomePage(),
            routes: [
              GoRoute(
                  path: "tasks/:taskId",
                  name: "tasks",
                  builder: (BuildContext context, GoRouterState state) {
                    int id = int.parse(state.params['taskId']!);
                    return taskDetailScreen(taskId: id);
                  }
              ),
            ],
          ),

          GoRoute(
            path:'/createTasks',
            builder: (context, state)=> TaskForm(),
          )
        ]
    );

    final addTaskButton = find.byKey(const ValueKey('addTaskButton'));

    //execute test
    await tester.pumpWidget(
        MaterialApp(
          home:MultiProvider(
            providers: [
              ListenableProvider<MockdatabaseProvider>(create:
                  (context) => mockDBprovider),
            ],
            child:MaterialApp.router(
              title: 'task app',
              routerConfig: _router,
            ),
          ),
          navigatorObservers: [
            observerMock,
          ],
        )
    );

    await tester.tap(addTaskButton);
    verify(observerMock.didPush(any, any));
    await tester.pump();
  });

}
