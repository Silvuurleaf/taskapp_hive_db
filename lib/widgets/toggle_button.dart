import 'package:flutter/material.dart';

class ToggleButton extends StatefulWidget {


  final Function callbackFunction;
  const ToggleButton({Key? key, required this.callbackFunction}) : super(key: key);

  @override
  ToggleButtonState createState() => ToggleButtonState();
}

class ToggleButtonState extends State<ToggleButton> {

  List<bool> isSelected = [true, false];

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.green.withOpacity(.5),
    child: ToggleButtons(
        fillColor: Colors.lightBlue.shade900,
        selectedColor: Colors.white,
        isSelected: isSelected,
        renderBorder: false,
        children: const [
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('Personal',)
          ),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('Shared',)
          ),
        ],
        onPressed: (int newIndex){
          setState(() {
            for(int idx = 0; idx < isSelected.length; idx++ ){
              if(idx == newIndex){
                isSelected[idx] = !isSelected[idx];
              }
              else{
                isSelected[idx] = false;
              }
            }

            //check the first toggle button value
            bool isPersonal = isSelected[0];
            print("Is personal save task is: $isPersonal");
            widget.callbackFunction(isSelected[0]);
          });
        },
    ),
  );
}
