import 'package:flutter/material.dart';

class GoogleAppleWidget extends StatelessWidget {
  const GoogleAppleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 50,
          height: 50,
          child: Image.asset('assets/images/Google.png',width: 80,height: 80,),
        ),
        SizedBox(width: 50,),
        Container(
          width: 50,
          height: 50,
          child: Image.asset('assets/images/Apple.png',width: 80,height: 80,),
        )
      ],
    );
  }
}
