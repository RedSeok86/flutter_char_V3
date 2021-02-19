import 'package:flutter/material.dart';
import 'package:papucon/theme.dart';


class Loading extends StatelessWidget {
  const Loading();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(MyColors.primaryColor),
        ),
      ),
      color: Color(0xFFf2f3f6),
    );
  }
}
