import 'package:equatable/equatable.dart';

sealed class CallablePropertySchema extends Equatable {
  const CallablePropertySchema({required this.name, this.description, this.isRequired});

  final String name;
  final String? description;
  final bool? isRequired;

  @override
  List<Object?> get props => [name, description, isRequired];
}

class StringSchema extends CallablePropertySchema {
  const StringSchema({required super.name, super.description, super.isRequired});
}

class BooleanSchema extends CallablePropertySchema {
  const BooleanSchema({required super.name, super.description, super.isRequired});
}

class NumberSchema extends CallablePropertySchema {
  const NumberSchema({required super.name, super.description, super.isRequired});
}

class IntSchema extends CallablePropertySchema {
  const IntSchema({required super.name, super.description, super.isRequired});
}

class ListSchema extends CallablePropertySchema {
  const ListSchema({required super.name, super.description, super.isRequired, required this.type});

  final ListType type;

  @override
  List<Object?> get props => [...super.props, type];
}

class EnumSchema extends CallablePropertySchema {
  const EnumSchema({required super.name, super.description, super.isRequired, required this.options});

  final List<String> options;

  @override
  List<Object?> get props => [...super.props, options];
}

class ObjectSchema extends CallablePropertySchema {
  const ObjectSchema({required super.name, super.description, super.isRequired, required this.properties});

  final List<CallablePropertySchema> properties;

  @override
  List<Object?> get props => [...super.props, properties];
}

class NullSchema extends CallablePropertySchema {
  const NullSchema({required super.name, super.description, super.isRequired});
}

class InvalidSchema extends CallablePropertySchema {
  const InvalidSchema({required super.name, super.description, super.isRequired = false, required this.error});

  final String error;

  @override
  List<Object?> get props => [...super.props, error];
}

enum ListType { int, num, string, boolean, enumerated, object, unknown }
