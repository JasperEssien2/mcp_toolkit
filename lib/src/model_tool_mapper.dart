import 'dart:mirrors';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:mcp_toolkit/src/annotations/annotations.dart';
import 'package:meta/meta.dart';

class ModelToolMapper {
  ModelToolMapper({required this.toolInput});

  final List<Type> toolInput;

  CallableTool? extract(Type tool) {
    final reflected = reflectClass(tool);

    if (reflected.metadata
            .firstWhereOrNull((e) => e.reflectee is CallableToolInput)
            ?.reflectee
        case CallableToolInput(:final name, :final description)) {
      List<CallablePropertySchema> properties = _getCallablePropertiesFromClass(
        reflected,
      );

      return CallableTool(
        toolName: name,
        toolDescription: description,
        properties: properties,
      );
    }

    return null;
  }

  ListSchema _handleList(
    VariableMirror value, {
    required String name,
    required String description,
    required bool isRequired,
  }) => ListSchema(
    name: name,
    description: description,
    isRequired: isRequired,
    type: switch (value.type.typeArguments.firstOrNull?.simpleName) {
      #int => ListType.int,
      #num => ListType.num,
      #String => ListType.string,
      #bool => ListType.boolean,
      // TODO(jasperessien): Handle object type and enumerated type
      _ => ListType.unknown,
    },
  );

  CallablePropertySchema _handleOtherType(
    VariableMirror value, {
    required String name,
    required String description,
    required bool isRequired,
  }) {
    final reflected = reflectClass(value.type.reflectedType);

    final options = reflected.declarations.keys
        .where((e) => _isEnumValue(e, reflected))
        .map((e) => MirrorSystem.getName(e))
        .toList();

    if (reflected.isEnum) {
      // TODO(jasperessien): What happens when enum has variables?
      return EnumSchema(
        name: name,
        description: description,
        isRequired: isRequired,
        options: options,
      );
    }

    if (reflected.simpleName case #Record) {
      // TODO(jasperessien): No way to extract record variables/declaration using dart::mirror
      return InvalidSchema(
        name: name,
        description: description,
        error: 'Does not support Record type',
      );
    }

    if (_getCallablePropertiesFromClass(reflected) case final properties
        when properties.isNotEmpty) {
      return ObjectSchema(
        name: name,
        description: description,
        isRequired: isRequired,
        properties: properties,
      );
    }

    return InvalidSchema(
      name: name,
      description: description,
      error: 'Cannot handle type ${reflected.reflectedType}',
    );
  }

  bool _isEnumValue(Symbol e, ClassMirror reflected) => switch (e) {
    #values => false,
    // TODO(jasperessien): Investigate why this doesn't work as a work around, the below is used
    #_enumToString => false,
    _ when MirrorSystem.getName(e) == '_enumToString' => false,
    _ when e == reflected.simpleName => false,
    _ => true,
  };

  dynamic _findCallableToolPropertyFromDeclaration(
    MapEntry<Symbol, DeclarationMirror> declaration,
  ) => declaration.value.metadata
      .firstWhereOrNull((e) => e.reflectee is CallableToolProperty)
      ?.reflectee;

  List<CallablePropertySchema> _getCallablePropertiesFromClass(
    ClassMirror reflected,
  ) {
    final properties = <CallablePropertySchema>[];

    for (final declaration in reflected.declarations.entries) {
      if (_findCallableToolPropertyFromDeclaration(declaration)
          case CallableToolProperty(
            :final description,
            :final isRequired,
            :final name,
          )) {
        final fieldName =
            name ?? MirrorSystem.getName(declaration.value.simpleName);

        if (declaration.value case VariableMirror()) {
          final property =
              switch ((declaration.value as VariableMirror).type.simpleName) {
                #int => IntSchema(
                  name: fieldName,
                  description: description,
                  isRequired: isRequired,
                ),
                #num => NumberSchema(
                  name: fieldName,
                  description: description,
                  isRequired: isRequired,
                ),
                #String => StringSchema(
                  name: fieldName,
                  description: description,
                  isRequired: isRequired,
                ),
                #bool => BooleanSchema(
                  name: fieldName,
                  description: description,
                  isRequired: isRequired,
                ),
                #List => _handleList(
                  declaration.value as VariableMirror,
                  name: fieldName,
                  description: description,
                  isRequired: isRequired,
                ),
                _ => _handleOtherType(
                  declaration.value as VariableMirror,
                  name: fieldName,
                  description: description,
                  isRequired: isRequired,
                ),
              };
          properties.add(property);
        }
      }
    }

    return properties;
  }
}

@visibleForTesting
class CallableTool extends Equatable {
  const CallableTool({
    required this.toolName,
    required this.toolDescription,
    required this.properties,
  });

  final String toolName;
  final String toolDescription;
  final List<CallablePropertySchema> properties;

  @override
  List<Object> get props => [toolName, toolDescription, properties];
}

@visibleForTesting
sealed class CallablePropertySchema extends Equatable {
  const CallablePropertySchema({
    required this.name,
    required this.description,
    required this.isRequired,
  });

  final String name;
  final String description;
  final bool isRequired;

  @override
  List<Object?> get props => [name, description, isRequired];
}

class StringSchema extends CallablePropertySchema {
  const StringSchema({
    required super.name,
    required super.description,
    required super.isRequired,
  });
}

class BooleanSchema extends CallablePropertySchema {
  const BooleanSchema({
    required super.name,
    required super.description,
    required super.isRequired,
  });
}

class NumberSchema extends CallablePropertySchema {
  const NumberSchema({
    required super.name,
    required super.description,
    required super.isRequired,
  });
}

class IntSchema extends CallablePropertySchema {
  const IntSchema({
    required super.name,
    required super.description,
    required super.isRequired,
  });
}

class ListSchema extends CallablePropertySchema {
  const ListSchema({
    required super.name,
    required super.description,
    required super.isRequired,
    required this.type,
  });

  final ListType type;

  @override
  List<Object?> get props => [...super.props, type];
}

class EnumSchema extends CallablePropertySchema {
  const EnumSchema({
    required super.name,
    required super.description,
    required super.isRequired,
    required this.options,
  });

  final List<String> options;

  @override
  List<Object?> get props => [...super.props, options];
}

class ObjectSchema extends CallablePropertySchema {
  const ObjectSchema({
    required super.name,
    required super.description,
    required super.isRequired,
    required this.properties,
  });

  final List<CallablePropertySchema> properties;

  @override
  List<Object?> get props => [...super.props, properties];
}

class NullSchema extends CallablePropertySchema {
  const NullSchema({
    required super.name,
    required super.description,
    required super.isRequired,
  });
}

class InvalidSchema extends CallablePropertySchema {
  InvalidSchema({
    required super.name,
    required super.description,
    super.isRequired = false,
    required this.error,
  });

  final String error;

  @override
  List<Object?> get props => [...super.props, error];
}

enum ListType { int, num, string, boolean, enumerated, object, unknown }
