import 'package:flutter/material.dart';
import 'package:papucon/theme.dart';

class LoaderHUD extends StatelessWidget {
  final bool inAsyncCall;
  final double opacity;
  final Color color;
  final Widget progressIndicator = Container(
    width: 200,
    height: 100,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    child: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(MyColors.primaryColor),)),
  );
  final bool dismissible;
  final Widget child;

    LoaderHUD({
        Key key,
        @required this.inAsyncCall,
        this.opacity = 0.3,
        this.color = Colors.grey,
        this.dismissible = false,
        @required this.child,
    })  : assert(child != null),
            assert(inAsyncCall != null),
            super(key: key);

    @override
    Widget build(BuildContext context) {
        if (!inAsyncCall) return child;

        return Stack(
            children: [
                child,
                Opacity(
                    child: ModalBarrier(dismissible: dismissible, color: color),
                    opacity: opacity,
                ),
                Center(child: progressIndicator),
            ],
        );
    }
}
