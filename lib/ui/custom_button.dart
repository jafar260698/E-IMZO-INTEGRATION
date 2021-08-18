
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final Function onPressed;
  final bool isLoading;

  const CustomButton(
      {Key key,
         this.title,
         this.onPressed,
         this.isLoading})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: Color(0xff1171FF).withOpacity(0.3),
        child: CupertinoButton(
          padding: isLoading
              ? EdgeInsets.all(0)
              : EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 100,
          ),
          borderRadius: BorderRadius.circular(16),
          color: Color(0xff1171FF),
          onPressed: onPressed,
          child: isLoading
              ? loadingWidget()
              : Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
      ),
    );
  }
}

Widget loadingWidget() {
  return Padding(
    padding: EdgeInsets.only(
      right: 16,
      left: 16,
    ),
    child: SizedBox(
      width: 36,
      height: 36,
      child: SpinKitDualRing(
        color: Colors.white,
        size: 36,
        // strokeWidth: SizeConfig.calculateBlockHorizontal(3),
        // backgroundColor: Colors.white,
      ),
    ),
  );
}
