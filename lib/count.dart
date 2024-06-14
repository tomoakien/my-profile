import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
part 'count.g.dart';

@HiveType(typeId: 1)
class Count {
  @HiveField(0)
  int count;
  Count({required this.count});
}
