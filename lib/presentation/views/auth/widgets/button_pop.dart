import 'package:flutter/material.dart';

class ButtonPop extends StatelessWidget {
  const ButtonPop({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      height: 30,
      width: 30,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          boxShadow: [BoxShadow(color: Color(0xFFEEEEEE))]
      ),
      child: ElevatedButton(onPressed: (){
        Navigator.pop(context);
      },
        style: ElevatedButton.styleFrom(
            shape:CircleBorder(),
            padding:const EdgeInsets.all(9),
            backgroundColor: Colors.transparent
        ), child:  Icon(Icons.arrow_back_ios,color: Color(0xFF757575),size: 15,),
      ),
    );
  }
}
