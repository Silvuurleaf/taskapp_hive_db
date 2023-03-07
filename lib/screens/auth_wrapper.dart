import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/authenticate.dart';
import '../models/taskUser.dart';

import 'home_page.dart';

class auth_wrapper extends StatelessWidget {
  const auth_wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final task_user = Provider.of<taskUser?>(context);
    print('task user auth wrapper: $task_user');

    //check if there's a user or not

    if(task_user == null){
      return Authenticate();
    }else{
      return MyHomePage();
    }

  }
}
