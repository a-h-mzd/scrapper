import 'package:flutter/material.dart';

class CText extends Text {
  CText(Object data, {TextAlign textAlign})
      : super(
          data is String ? data : data.toString(),
          textAlign: textAlign,
          style: const TextStyle(fontFamily: 'Roboto'),
        );
}
