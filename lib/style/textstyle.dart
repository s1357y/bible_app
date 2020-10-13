import 'package:flutter/material.dart';
import 'package:neon/neon.dart';

Text CustomText(String text ,double size){
  return Text(text,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: size)
  );
}

Text CustomTextColor(String text ,double size, Color color){
  return Text(text,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: size, color: color)
  );
}

Neon NeonText(String text, double fontsize, Color color){
  return Neon(
    text: text,
    color: color,
    fontSize: fontsize,
    font: NeonFont.Membra,
    flickeringText: true,
    flickeringLetters: null,
    glowingDuration: Duration(seconds: 3),
  );
}