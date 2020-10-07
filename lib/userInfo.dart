import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserInfo{

  final int inCircle;
  final int whichCircle;
  final bool isfinished;
  final String username;
  DocumentReference reference;

  UserInfo({this.inCircle, this.isfinished, this.username, this.whichCircle});

  UserInfo.fromMap(Map<String,dynamic> map, {this.reference})
    : inCircle = map['incircle'],
      whichCircle = map['whichcircle'],
      isfinished = map['finished'],
      username = map['name'];

  UserInfo.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data());

}