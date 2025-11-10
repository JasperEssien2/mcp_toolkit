import 'package:collection/collection.dart';
import 'package:mcp_toolkit/src/annotations/annotations.dart';
import 'package:mcp_toolkit/src/mcp_model_tool_mapper.dart';
import 'package:mcp_toolkit/src/models/callable_property_schema.dart';
import 'package:test/test.dart';

// Dummy classes for testing
enum TestEnum {
  value1,
  value2,
}

@MCPToolInput(toolName: 'simple_tool', toolDescription: 'A simple test tool')
class SimpleToolInput {
  const SimpleToolInput({required this.param1, this.param2});

  @MCPToolProperty(description: 'The first parameter', isRequired: true)
  final String param1;

  @MCPToolProperty(description: 'The second parameter', isRequired: false)
  final int? param2;
}

@MCPToolInput(toolName: 'complex_tool')
class ComplexToolInput {
  const ComplexToolInput({
    required this.name,
    required this.age,
    required this.items,
    required this.nested,
    required this.status,
  });

  @MCPToolProperty(description: 'User name', isRequired: true)
  final String name;

  @MCPToolProperty(description: 'User age')
  final int age;

  @MCPToolProperty(description: 'List of items')
  final List<String> items;

  @MCPToolProperty(description: 'Nested object')
  final NestedObject nested;

  @MCPToolProperty(description: 'Status of the user')
  final TestEnum status;
}

class NestedObject {
  const NestedObject({required this.id, required this.value});

  @MCPToolProperty(name: 'nested_id', isRequired: true)
  final String id;

  @MCPToolProperty()
  final bool value;
}

@MCPToolInput(toolName: 'list_of_objects_tool')
class ListOfObjectsToolInput {
  const ListOfObjectsToolInput({required this.data});

  @MCPToolProperty(description: 'List of data objects')
  final List<NestedObject> data;
}

@MCPToolInput(toolName: 'tool_with_custom_names')
class CustomNamesToolInput {
  const CustomNamesToolInput({required this.firstParam, required this.secondParam});

  @MCPToolProperty(name: 'custom_first_param', description: 'Custom named first parameter')
  final String firstParam;

  @MCPToolProperty(name: 'custom_second_param')
  final int secondParam;
}

// Tool with no properties
@MCPToolInput(toolName: 'no_properties_tool')
class NoPropertiesToolInput {
  const NoPropertiesToolInput();
}

// Tool with no MCPToolInput annotation
class NoAnnotationToolInput {
  const NoAnnotationToolInput({required this.param});

  @MCPToolProperty()
  final String param;
}

// Tool with unsupported type (Record)
@MCPToolInput(toolName: 'unsupported_record_tool')
class UnsupportedRecordToolInput {
  const UnsupportedRecordToolInput({required this.record});

  @MCPToolProperty()
  final ({String a, int b}) record;
}

void main() {
  group('ModelToolMapper', () {
    late ModelToolMapper mapper;

    setUp(() {
      mapper = ModelToolMapper(
        toolModelTypes: [
          SimpleToolInput,
          ComplexToolInput,
          ListOfObjectsToolInput,
          CustomNamesToolInput,
          NoPropertiesToolInput,
          NoAnnotationToolInput,
          UnsupportedRecordToolInput,
        ],
      );
    });

    group('callableTools', () {
      test('should correctly map a simple tool', () {
        final callableTools = mapper.callableTools();
        final simpleTool = callableTools.firstWhere((tool) => tool.toolName == 'simple_tool');

        expect(simpleTool.toolName, 'simple_tool');
        expect(simpleTool.toolDescription, 'A simple test tool');
        expect(simpleTool.properties.length, 2);

        final param1 = simpleTool.properties.firstWhere((p) => p.name == 'param1') as StringSchema;
        expect(param1.name, 'param1');
        expect(param1.description, 'The first parameter');
        expect(param1.isRequired, isTrue);

        final param2 = simpleTool.properties.firstWhere((p) => p.name == 'param2') as IntSchema;
        expect(param2.name, 'param2');
        expect(param2.description, 'The second parameter');
        expect(param2.isRequired, isFalse);
      });

      test('should correctly map a complex tool with nested objects, lists, and enums', () {
        final callableTools = mapper.callableTools();
        final complexTool = callableTools.firstWhere((tool) => tool.toolName == 'complex_tool');

        expect(complexTool.toolName, 'complex_tool');
        expect(complexTool.toolDescription, isNull);
        expect(complexTool.properties.length, 5);

        final name = complexTool.properties.firstWhere((p) => p.name == 'name') as StringSchema;
        expect(name.name, 'name');
        expect(name.description, 'User name');
        expect(name.isRequired, isTrue);

        final age = complexTool.properties.firstWhere((p) => p.name == 'age') as IntSchema;
        expect(age.name, 'age');
        expect(age.description, 'User age');
        expect(age.isRequired, isNull);

        final items = complexTool.properties.firstWhere((p) => p.name == 'items') as ListSchema;
        expect(items.name, 'items');
        expect(items.description, 'List of items');
        expect(items.isRequired, isNull);
        expect(items.type, const StringSchema.type());

        final nested = complexTool.properties.firstWhere((p) => p.name == 'nested') as ObjectSchema;
        expect(nested.name, 'nested');
        expect(nested.description, 'Nested object');
        expect(nested.isRequired, isNull);
        expect(nested.properties.length, 2);

        final nestedId = nested.properties.firstWhere((p) => p.name == 'nested_id') as StringSchema;
        expect(nestedId.name, 'nested_id');
        expect(nestedId.isRequired, isTrue);

        final nestedValue = nested.properties.firstWhere((p) => p.name == 'value') as BooleanSchema;
        expect(nestedValue.name, 'value');
        expect(nestedValue.isRequired, isNull);

        final status = complexTool.properties.firstWhere((p) => p.name == 'status') as EnumSchema;
        expect(status.name, 'status');
        expect(status.description, 'Status of the user');
        expect(status.options, ['value1', 'value2']);
      });

      test('should correctly map a tool with a list of objects', () {
        final callableTools = mapper.callableTools();
        final listOfObjectsTool = callableTools.firstWhere((tool) => tool.toolName == 'list_of_objects_tool');

        expect(listOfObjectsTool.toolName, 'list_of_objects_tool');
        expect(listOfObjectsTool.properties.length, 1);

        final data = listOfObjectsTool.properties.firstWhere((p) => p.name == 'data') as ListSchema;
        expect(data.name, 'data');
        expect(data.description, 'List of data objects');
        expect(data.type, isA<ObjectSchema>());

        final nestedObjectSchema = data.type as ObjectSchema;
        expect(nestedObjectSchema.properties.length, 2);
        expect(
          nestedObjectSchema.properties.firstWhere((p) => p.name == 'nested_id') as StringSchema,
          isA<StringSchema>(),
        );
        expect(
          nestedObjectSchema.properties.firstWhere((p) => p.name == 'value') as BooleanSchema,
          isA<BooleanSchema>(),
        );
      });

      test('should correctly map properties with custom names', () {
        final callableTools = mapper.callableTools();
        final customNamesTool = callableTools.firstWhere((tool) => tool.toolName == 'tool_with_custom_names');

        expect(customNamesTool.toolName, 'tool_with_custom_names');
        expect(customNamesTool.properties.length, 2);

        final firstParam = customNamesTool.properties.firstWhere((p) => p.name == 'custom_first_param') as StringSchema;
        expect(firstParam.name, 'custom_first_param');
        expect(firstParam.description, 'Custom named first parameter');

        final secondParam = customNamesTool.properties.firstWhere((p) => p.name == 'custom_second_param') as IntSchema;
        expect(secondParam.name, 'custom_second_param');
      });

      test('should return an empty list of properties for a tool with no properties', () {
        final callableTools = mapper.callableTools();
        final noPropertiesTool = callableTools.firstWhere((tool) => tool.toolName == 'no_properties_tool');

        expect(noPropertiesTool.toolName, 'no_properties_tool');
        expect(noPropertiesTool.properties, isEmpty);
      });

      test('should return null for a class without MCPToolInput annotation', () {
        final callableTools = mapper.callableTools();
        final noAnnotationTool = callableTools.firstWhereOrNull((tool) => tool?.toolName == 'no_annotation_tool');
        expect(noAnnotationTool, isNull);
      });

      test('should return InvalidSchema for unsupported Record type', () {
        final callableTools = mapper.callableTools();
        final unsupportedRecordTool = callableTools.firstWhere((tool) => tool.toolName == 'unsupported_record_tool');

        expect(unsupportedRecordTool.toolName, 'unsupported_record_tool');
        expect(unsupportedRecordTool.properties.length, 1);

        final recordProperty = unsupportedRecordTool.properties.firstWhere((p) => p.name == 'record') as InvalidSchema;
        expect(recordProperty.name, 'record');
        expect(recordProperty.error, 'Does not support Record type');
      });
    });
  });
}
