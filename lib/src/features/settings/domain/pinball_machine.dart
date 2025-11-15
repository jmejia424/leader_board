// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

class PinballMachine extends Equatable {
  final String id;
  final String name;

  const PinballMachine({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];

  @override
  bool get stringify => true;

  PinballMachine copyWith({String? id, String? name}) {
    return PinballMachine(id: id ?? this.id, name: name ?? this.name);
  }

  // Convert PinballMachine to Map
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  // Create PinballMachine from Map
  factory PinballMachine.fromMap(Map<String, dynamic> map) {
    return PinballMachine(id: map['id'] as String, name: map['name'] as String);
  }

  // Convert PinballMachine to JSON
  String toJson() => json.encode(toMap());

  // Create PinballMachine from JSON
  factory PinballMachine.fromJson(String source) =>
      PinballMachine.fromMap(json.decode(source) as Map<String, dynamic>);
}
