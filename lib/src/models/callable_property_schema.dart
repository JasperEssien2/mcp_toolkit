import 'package:equatable/equatable.dart';

sealed class CallablePropertySchema extends Equatable {
  const CallablePropertySchema({this.name, this.description, this.isRequired});

  final String? name;
  final String? description;
  final bool? isRequired;

  Map<String, dynamic> toJson();

  String get jsonType;

  @override
  List<Object?> get props => [name, description, isRequired, jsonType];
}

final class StringSchema extends CallablePropertySchema {
  const StringSchema({super.name, super.description, super.isRequired});

  const StringSchema.type() : super(name: null);

  @override
  String get jsonType => 'string';

  @override
  Map<String, dynamic> toJson() => {'type': jsonType, 'description': ?description};
}

final class BooleanSchema extends CallablePropertySchema {
  const BooleanSchema({super.name, super.description, super.isRequired});

  const BooleanSchema.type() : super(name: null);

  @override
  String get jsonType => 'boolean';

  @override
  Map<String, dynamic> toJson() => {'type': jsonType, 'description': ?description};
}

final class NumberSchema extends CallablePropertySchema {
  const NumberSchema({super.name, super.description, super.isRequired});

  const NumberSchema.type() : super(name: null);

  @override
  String get jsonType => 'number';

  @override
  Map<String, dynamic> toJson() => {'type': jsonType, 'description': ?description};
}

final class IntSchema extends CallablePropertySchema {
  const IntSchema({super.name, super.description, super.isRequired});

  const IntSchema.type() : super(name: null);

  @override
  String get jsonType => 'integer';

  @override
  Map<String, dynamic> toJson() => {'type': jsonType, 'description': ?description};
}

final class ListSchema extends CallablePropertySchema {
  const ListSchema({super.name, super.description, super.isRequired, required this.type});

  final CallablePropertySchema type;

  @override
  String get jsonType => 'array';

  @override
  List<Object?> get props => [...super.props, type];

  @override
  Map<String, dynamic> toJson() => {
    'type': jsonType,
    'description': ?description,
    'items': type.toJson(),
  };
}

final class EnumSchema extends CallablePropertySchema {
  const EnumSchema({super.name, super.description, super.isRequired, required this.options});

  final List<String> options;

  @override
  String get jsonType => 'string';

  @override
  List<Object?> get props => [...super.props, options];

  @override
  Map<String, dynamic> toJson() => {
    'type': jsonType,
    'description': ?description,
    'enum': options,
  };
}

final class ObjectSchema extends CallablePropertySchema {
  const ObjectSchema({
    super.name,
    super.description,
    super.isRequired,
    this.properties,
    this.requiredProperties,
  });

  final List<CallablePropertySchema>? properties;
  final List<String>? requiredProperties;

  @override
  String get jsonType => 'object';

  @override
  List<Object?> get props => [...super.props, properties, requiredProperties];

  @override
  Map<String, dynamic> toJson() => {
    'type': jsonType,
    'description': ?description,
    if (properties case final properties?)
      'properties': {for (final property in properties) property.name: property.toJson()},
    'required': requiredProperties,
  };
}

final class NullSchema extends CallablePropertySchema {
  const NullSchema({required super.name, super.description, super.isRequired});

  @override
  String get jsonType => 'null';

  @override
  Map<String, dynamic> toJson() => {'type': jsonType, 'description': ?description};
}

final class InvalidSchema extends CallablePropertySchema {
  const InvalidSchema({required super.name, super.description, super.isRequired = false, required this.error});

  final String error;

  @override
  String get jsonType => 'invalid';

  @override
  List<Object?> get props => [...super.props, error];

  @override
  Map<String, dynamic> toJson() => {};
}
