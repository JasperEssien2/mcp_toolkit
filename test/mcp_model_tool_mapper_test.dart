import 'package:mcp_toolkit/src/annotations/annotations.dart';
import 'package:mcp_toolkit/src/mcp_model_tool_mapper.dart';
import 'package:mcp_toolkit/src/models/callable_property_schema.dart';
import 'package:mcp_toolkit/src/models/callable_tool.dart';
import 'package:test/test.dart';

void main() {
  group('MCPModelToolMapper', () {
    test('ensure mapper returns correct structure for SimpleToolModel', () {
      final model = MCPModelToolMapper(toolModelTypes: [SimpleToolInput]);

      expect(
        model.callableTools(),
        [
          const CallableTool(
            toolName: 'simple_tool',
            toolDescription: 'A simple test tool',
            properties: [
              StringSchema(name: 'param1', description: 'The first parameter', isRequired: true),
              IntSchema(name: 'param2', description: 'The second parameter', isRequired: false),
              BooleanSchema(name: 'boolean_param', description: 'The third parameter', isRequired: false),
            ],
          ),
        ],
      );
    });
  });
}

@MCPToolInput(toolName: 'simple_tool', toolDescription: 'A simple test tool')
class SimpleToolInput {
  const SimpleToolInput({required this.param1, this.param2, required this.param3});

  @MCPToolProperty(description: 'The first parameter', isRequired: true)
  final String param1;

  @MCPToolProperty(description: 'The second parameter', isRequired: false)
  final int? param2;

  @MCPToolProperty(description: 'The third parameter', isRequired: false, name: 'boolean_param')
  final bool? param3;
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

enum TestEnum {
  value1,
  value2,
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
