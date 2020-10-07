import 'package:flutter/material.dart';

Text CustomText(String text ,double size){
  return Text(text,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: size)
  );
}