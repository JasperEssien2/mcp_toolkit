import 'package:mcp_toolkit/src/annotations/annotations.dart';
import 'package:mcp_toolkit/src/mcp_model_tool_mapper.dart';
import 'package:mcp_toolkit/src/models/callable_property_schema.dart';
import 'package:mcp_toolkit/src/models/callable_tool.dart';
import 'package:test/test.dart';

void main() {
  group('MCPModelToolMapper', () {
    group('Test callableTools', () {
      test('ensure mapper returns correct structure for SimpleToolModel', () {
        final model = MCPModelToolMapper(toolInput: [SimpleToolInput])..initialize();

        expect(
          model.callableTools,
          [
            const CallableTool(
              toolName: 'simple_tool',
              toolDescription: 'A simple test tool',
              inputSchema: ObjectSchema(
                properties: [
                  StringSchema(name: 'param1', description: 'The first parameter', isRequired: true),
                  IntSchema(name: 'param2', description: 'The second parameter', isRequired: false),
                  BooleanSchema(name: 'boolean_param', description: 'The third parameter', isRequired: false),
                ],
                requiredProperties: ['param1'],
              ),
            ),
          ],
        );
      });

      test('ensure mapper returns correct structure for ComplexToolInput', () {
        final model = MCPModelToolMapper(toolInput: [ComplexToolInput])..initialize();

        expect(
          model.callableTools,
          [
            const CallableTool(
              toolName: 'complex_tool',
              inputSchema: ObjectSchema(
                properties: [
                  StringSchema(name: 'name', description: 'User name', isRequired: true),
                  IntSchema(name: 'age', description: 'User age'),
                  ListSchema(name: 'items', description: 'List of items', type: StringSchema.type()),
                  ObjectSchema(
                    name: 'nested',
                    description: 'Nested object',
                    properties: [
                      StringSchema(name: 'nested_id', isRequired: true),
                      BooleanSchema(name: 'value'),
                    ],
                    requiredProperties: ['nested_id'],
                  ),
                  EnumSchema(name: 'status', description: 'Status of the user', options: ['value1', 'value2']),
                ],
                requiredProperties: ['name'],
              ),
            ),
          ],
        );
      });

      test('ensure mapper returns correct structure for ListOfObjectsToolInput', () {
        final model = MCPModelToolMapper(toolInput: [ListOfObjectsToolInput])..initialize();

        expect(
          model.callableTools,
          [
            const CallableTool(
              toolName: 'list_of_objects_tool',
              inputSchema: ObjectSchema(
                properties: [
                  ListSchema(
                    name: 'data',
                    description: 'List of data objects',
                    type: ObjectSchema(
                      name: null,
                      properties: [
                        StringSchema(name: 'nested_id', isRequired: true),
                        BooleanSchema(name: 'value'),
                      ],
                      requiredProperties: ['nested_id'],
                    ),
                    isRequired: true,
                  ),
                ],
                requiredProperties: ['data'],
              ),
            ),
          ],
        );
      });

      test('ensure mapper returns correct structure for CustomNamesToolInput', () {
        final model = MCPModelToolMapper(toolInput: [CustomNamesToolInput])..initialize();

        expect(
          model.callableTools,
          [
            const CallableTool(
              toolName: 'tool_with_custom_names',
              inputSchema: ObjectSchema(
                properties: [
                  StringSchema(name: 'custom_first_param', description: 'Custom named first parameter'),
                  IntSchema(name: 'custom_second_param'),
                ],
                requiredProperties: [],
              ),
            ),
          ],
        );
      });

      test('ensure mapper returns correct structure for NoPropertiesToolInput', () {
        final model = MCPModelToolMapper(toolInput: [NoPropertiesToolInput])..initialize();

        expect(
          model.callableTools,
          [
            const CallableTool(
              toolName: 'no_properties_tool',
              inputSchema: ObjectSchema(
                properties: [],
                requiredProperties: [],
              ),
            ),
          ],
        );
      });

      test('ensure mapper ignores classes without MCPToolInput annotation', () {
        final model = MCPModelToolMapper(toolInput: [NoAnnotationToolInput])..initialize();

        expect(model.callableTools, isEmpty);
      });

      test('ensure mapper returns InvalidSchema for UnsupportedRecordToolInput', () {
        final model = MCPModelToolMapper(toolInput: [UnsupportedRecordToolInput])..initialize();

        expect(
          model.callableTools,
          [
            const CallableTool(
              toolName: 'unsupported_record_tool',
              inputSchema: ObjectSchema(
                properties: [
                  InvalidSchema(name: 'record', error: 'Does not support Record type'),
                ],
                requiredProperties: [],
              ),
            ),
          ],
        );
      });

      test('ensure mapper returns an empty list for empty toolModelTypes', () {
        final model = MCPModelToolMapper(toolInput: [])..initialize();

        expect(model.callableTools, isEmpty);
      });

      test('ensure mapper returns an empty list for a tool with MCPToolInput but no properties', () {
        final model = MCPModelToolMapper(toolInput: [ToolWithNoPropertiesButAnnotation])..initialize();

        expect(
          model.callableTools,
          [
            const CallableTool(
              toolName: 'tool_with_no_properties_but_annotation',
              inputSchema: ObjectSchema(
                properties: [],
                requiredProperties: [],
              ),
            ),
          ],
        );
      });

      test('ensure mapper ignores classes with MCPToolProperty annotations but no MCPToolInput annotation', () {
        final model = MCPModelToolMapper(toolInput: [ToolWithPropertiesButNoInputAnnotation])..initialize();

        expect(model.callableTools, isEmpty);
      });

      test('ensure mapper ignores classes with MCPToolProperty annotations but no MCPToolInput annotation', () {
        final model = MCPModelToolMapper(toolInput: [ToolWithPropertiesButNoInputAnnotation])..initialize();

        expect(model.callableTools, isEmpty);
      });
    });
  });

  test('ensure mapper returns correct structure for EnumWithMethodsToolInput', () {
    final model = MCPModelToolMapper(toolInput: [EnumWithMethodsToolInput])..initialize();

    expect(
      model.callableTools,
      [
        const CallableTool(
          toolName: 'enum_with_methods_tool',
          inputSchema: ObjectSchema(
            properties: [
              EnumSchema(
                name: 'action',
                description: 'Action with methods',
                options: ['start', 'stop'],
                isRequired: true,
              ),
            ],
            requiredProperties: ['action'],
          ),
        ),
      ],
    );
  });

  test('ensure mapper returns correct structure for EnumWithVariableToolInput and excludes variable from options', () {
    final model = MCPModelToolMapper(toolInput: [EnumWithVariableToolInput])..initialize();

    expect(
      model.callableTools,
      [
        const CallableTool(
          toolName: 'enum_with_variable_tool',
          inputSchema: ObjectSchema(
            properties: [
              EnumSchema(name: 'action', description: 'Action with a variable', options: ['start', 'stop']),
            ],
            requiredProperties: [],
          ),
        ),
      ],
    );
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

  @MCPToolProperty(description: 'List of data objects', isRequired: true)
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

class ToolWithPropertiesButNoInputAnnotation {
  const ToolWithPropertiesButNoInputAnnotation({required this.param});

  @MCPToolProperty(description: 'A parameter without tool input annotation', isRequired: true)
  final String param;
}

@MCPToolInput(toolName: 'tool_with_no_properties_but_annotation')
class ToolWithNoPropertiesButAnnotation {
  const ToolWithNoPropertiesButAnnotation();
}

@MCPToolInput(toolName: 'no_properties_tool')
class NoPropertiesToolInput {
  const NoPropertiesToolInput();
}

class NoAnnotationToolInput {
  const NoAnnotationToolInput({required this.param});

  @MCPToolProperty()
  final String param;
}

@MCPToolInput(toolName: 'unsupported_record_tool')
class UnsupportedRecordToolInput {
  const UnsupportedRecordToolInput({required this.record});

  @MCPToolProperty()
  final ({String a, int b}) record;
}

@MCPToolInput(toolName: 'enum_with_methods_tool')
class EnumWithMethodsToolInput {
  const EnumWithMethodsToolInput({required this.action});

  @MCPToolProperty(description: 'Action with methods', isRequired: true)
  final ActionWithMethods action;
}

enum ActionWithMethods {
  start,
  stop;

  String describe() => 'This action is $name';
}

@MCPToolInput(toolName: 'enum_with_variable_tool')
class EnumWithVariableToolInput {
  const EnumWithVariableToolInput({required this.action});

  @MCPToolProperty(description: 'Action with a variable')
  final ActionWithVariable action;
}

enum ActionWithVariable {
  start('Start the process'),
  stop('Stop the process');

  const ActionWithVariable(this.description);

  final String description;
}
