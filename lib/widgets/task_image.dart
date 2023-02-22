import 'package:flutter/material.dart';
import 'dart:io';

class task_image extends StatefulWidget {

  //final File? imageFile;
  final String imageFilePath;
  final Function callbackFunction;
  const task_image({Key? key, required this.imageFilePath, required this.callbackFunction}) : super(key: key);

  @override
  State<task_image> createState() => _task_imageState();
}

class _task_imageState extends State<task_image> {

  @override
  Widget build(BuildContext context) {
    return ListView(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        children: [
          Column(
              key: const Key('Image_box'),
              children: [
                widget.imageFilePath == "" ?
                const Icon(Icons.image, size: 50) :
                Image.file(
                  File(widget.imageFilePath),
                  fit: BoxFit.fill,
                )
              ]
          ),

          ElevatedButton(
            key: const ValueKey('image_submit'),
            onPressed: () {
              widget.callbackFunction();
              //getGalleryImage();
            }, child: const Text('Add image'),
          ),
        ]
    );
  }
}
