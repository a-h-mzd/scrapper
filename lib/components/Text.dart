import 'package:flutter/material.dart';

class CText extends Text {
  CText(Object data,
      {TextAlign textAlign, FontWeight fontWeight, double fontSize=10})
      : super(
          data is String ? data : data.toString(),
          textAlign: textAlign,
          style: TextStyle(
            fontSize: fontSize,
            fontFamily: 'Roboto',
            fontWeight: fontWeight,
          ),
        );
}
