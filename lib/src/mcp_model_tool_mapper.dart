import 'dart:mirrors';

import 'package:collection/collection.dart';
import 'package:mcp_toolkit/src/annotations/annotations.dart';
import 'package:mcp_toolkit/src/models/callable_property_schema.dart';
import 'package:mcp_toolkit/src/models/callable_tool.dart';

//TODO(jasperessien): Introduce a method, get callable tool by name, use hash map implementation, maybe create initialize()
class MCPModelToolMapper {
  MCPModelToolMapper({required this.toolModelTypes});

  final List<Type> toolModelTypes;

  List<CallableTool> callableTools() => [for (final input in toolModelTypes) ?_callableToolFromInputType(input)];

  CallableTool? _callableToolFromInputType(Type toolInput) {
    final reflected = reflectClass(toolInput);

    if (reflected.metadata.firstWhereOrNull((e) => e.reflectee is MCPToolInput)?.reflectee case MCPToolInput(
      toolName: final name,
      toolDescription: final description,
    )) {
      final properties = _getCallablePropertiesFromClass(reflected);

      return CallableTool(toolName: name, toolDescription: description, properties: properties);
    }

    return null;
  }

  ListSchema _handleList(
    VariableMirror value, {
    required String name,
    required String? description,
    required bool? isRequired,
  }) => ListSchema(
    name: name,
    description: description,
    isRequired: isRequired,
    type: switch (value.type.typeArguments.firstOrNull?.simpleName) {
      #int => const IntSchema.type(),
      #num => const NumberSchema.type(),
      #String => const StringSchema.type(),
      #bool => const BooleanSchema.type(),
      _ => _handleOtherType(type: value.type.reflectedType, name: '', description: null, isRequired: null),
    },
  );

  CallablePropertySchema _handleOtherType({
    required Type type,
    required String name,
    required String? description,
    required bool? isRequired,
  }) {
    final reflected = reflectClass(type);

    if (reflected.isEnum) {
      final options = reflected.declarations.keys
          .where((e) => _isEnumValue(e, reflected))
          .map(MirrorSystem.getName)
          .toList();

      // TODO(jasperessien): What happens when enum has variables? and methods {basically enhanced enum features}
      return EnumSchema(name: name, description: description, isRequired: isRequired, options: options);
    }

    if (reflected.simpleName case #Record) {
      // TODO(jasperessien): No way to extract record variables/declaration using dart::mirror
      return InvalidSchema(name: name, description: description, error: 'Does not support Record type');
    }

    if (_getCallablePropertiesFromClass(reflected) case final properties when properties.isNotEmpty) {
      return ObjectSchema(name: name, description: description, isRequired: isRequired, properties: properties);
    }

    return InvalidSchema(name: name, description: description, error: 'Cannot handle type ${reflected.reflectedType}');
  }

  bool _isEnumValue(Symbol e, ClassMirror reflected) => switch (e) {
    #values => false,
    // TODO(jasperessien): Investigate why this doesn't work as a work around, the below is used
    #_enumToString => false,
    _ when MirrorSystem.getName(e) == '_enumToString' => false,
    _ when e == reflected.simpleName => false,
    _ => true,
  };

  // ignore: avoid_dynamic
  dynamic _findCallableToolPropertyFromDeclaration(MapEntry<Symbol, DeclarationMirror> declaration) =>
      declaration.value.metadata.firstWhereOrNull((e) => e.reflectee is MCPToolProperty)?.reflectee;

  List<CallablePropertySchema> _getCallablePropertiesFromClass(ClassMirror reflected) {
    final properties = <CallablePropertySchema>[];

    for (final declaration in reflected.declarations.entries) {
      if (_findCallableToolPropertyFromDeclaration(declaration) case MCPToolProperty(
        :final description,
        :final isRequired,
        :final name,
      )) {
        final fieldName = name ?? MirrorSystem.getName(declaration.value.simpleName);

        if (declaration.value case VariableMirror()) {
          final property = switch ((declaration.value as VariableMirror).type.simpleName) {
            #int => IntSchema(name: fieldName, description: description, isRequired: isRequired),
            #num => NumberSchema(name: fieldName, description: description, isRequired: isRequired),
            #String => StringSchema(name: fieldName, description: description, isRequired: isRequired),
            #bool => BooleanSchema(name: fieldName, description: description, isRequired: isRequired),
            #List => _handleList(
              declaration.value as VariableMirror,
              name: fieldName,
              description: description,
              isRequired: isRequired,
            ),
            _ => _handleOtherType(
              type: (declaration.value as VariableMirror).type.reflectedType,
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
