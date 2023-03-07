import 'package:firebase_auth/firebase_auth.dart';

import '../models/taskUser.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;


  //auth change user stream
  //gets info everythime user logs in or out and map it to our taskUser class
  Stream<taskUser?> get user{
    return _auth.authStateChanges()
        .map(_userFromFirebaseUser);
  }


  //create user obj using firebase user data
  taskUser? _userFromFirebaseUser(User? user){
    return user != null ? taskUser(uid: user.uid) : null;

  }

  //sign in anon
  //sign guest
  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      return _userFromFirebaseUser(user);

    }catch(e){
      print(e.toString());
      return null;
    }
  }

  //sign out
  Future signOut() async{
    try{
      return await _auth.signOut();
    }catch(e){
      print(e.toString());
      return null;
    }
  }

  //sign out

}