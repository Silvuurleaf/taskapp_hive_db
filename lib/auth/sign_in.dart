import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/hive_db_provider.dart';
import '../services/auth.dart';
import '../widgets/loading_widget.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final AuthService _auth = AuthService();
  String error = '';
  final _formKey = GlobalKey<FormState>();

  //loading true -> show loading widget
  bool loading = false;

  var taskDB;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _onAfterBuild(context));
  }

  void _onAfterBuild(BuildContext context) {
    taskDB = Provider.of<databaseProvider>(context, listen: false);

    try{
      taskDB.loadData();
    }
    catch (e){
      print(e.toString());
    }
  }


  @override
  Widget build(BuildContext context) {
    return loading ? const Loading_widget() : Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Sign in to task app'),

      ),

      body: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                ElevatedButton(onPressed: () async {
                  setState(() {
                    loading = true;
                  });
                  dynamic response = await _auth.signInAnon();

                  if(response == null){
                    print("error signing in");

                    setState(() {
                      loading = false;
                    });

                  }else{
                    print('signed in');
                    print(response.uid);
                    taskDB.setFirebaseUid(response.uid);
                  }

                } , child: const Text('Sign in'))

              ],
            ),
          )

      ),
    );
  }
}
