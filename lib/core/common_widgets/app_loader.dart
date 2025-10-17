import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppLoader extends StatelessWidget {
  final String? label;
  final double indicatorSize;
  final Color indicatorColor;

  const AppLoader({
    Key? key,
    this.label,
    this.indicatorSize = 40.0,
    this.indicatorColor = CupertinoColors.activeBlue,
  }) : super(key: key); // 👈 Added this

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoActivityIndicator(
            radius: indicatorSize,
            animating: true,
            color: indicatorColor, // 👉 Also you forgot to assign the color!
          ),
          if (label != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child:  Text(
                label ?? "",
                style: TextStyle(
                  fontSize: 16,
                  color: indicatorColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
