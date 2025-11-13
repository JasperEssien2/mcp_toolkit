import 'package:equatable/equatable.dart';

sealed class CallablePropertySchema extends Equatable {
  const CallablePropertySchema({required this.name, this.description, this.isRequired});

  String get jsonType;

  final String name;
  final String? description;
  final bool? isRequired;

  @override
  List<Object?> get props => [name, description, isRequired];
}

class StringSchema extends CallablePropertySchema {
  const StringSchema({required super.name, super.description, super.isRequired});

  const StringSchema.type() : super(name: '');

  @override
  String get jsonType => 'string';
}

class BooleanSchema extends CallablePropertySchema {
  const BooleanSchema({required super.name, super.description, super.isRequired});

  const BooleanSchema.type() : super(name: '');

  @override
  String get jsonType => 'boolean';
}

class NumberSchema extends CallablePropertySchema {
  const NumberSchema({required super.name, super.description, super.isRequired});

  const NumberSchema.type() : super(name: '');

  @override
  String get jsonType => 'number';
}

class IntSchema extends CallablePropertySchema {
  const IntSchema({required super.name, super.description, super.isRequired});

  const IntSchema.type() : super(name: '');

  @override
  String get jsonType => 'integer';
}

class ListSchema extends CallablePropertySchema {
  const ListSchema({required super.name, super.description, super.isRequired, required this.type});

  final CallablePropertySchema type;

  @override
  String get jsonType => 'array';

  @override
  List<Object?> get props => [...super.props, type];
}

class EnumSchema extends CallablePropertySchema {
  const EnumSchema({required super.name, super.description, super.isRequired, required this.options});

  final List<String> options;

  @override
  String get jsonType => 'string';

  @override
  List<Object?> get props => [...super.props, options];
}

class ObjectSchema extends CallablePropertySchema {
  const ObjectSchema({required super.name, super.description, super.isRequired, required this.properties});

  final List<CallablePropertySchema> properties;

  @override
  String get jsonType => 'object';

  @override
  List<Object?> get props => [...super.props, properties];
}

class NullSchema extends CallablePropertySchema {
  const NullSchema({required super.name, super.description, super.isRequired});

  @override
  String get jsonType => 'null';
}

class InvalidSchema extends CallablePropertySchema {
  const InvalidSchema({required super.name, super.description, super.isRequired = false, required this.error});

  final String error;

  @override
  String get jsonType => 'invalid';

  @override
  List<Object?> get props => [...super.props, error];
}
