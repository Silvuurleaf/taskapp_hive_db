import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading_widget extends StatelessWidget {
  const Loading_widget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueAccent,
      child: const Center(
        child: SpinKitChasingDots(
          color: Colors.red,
          size: 50,
        ),
      ),
    );
  }
}
