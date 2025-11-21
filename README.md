# dart_mcp_toolkit

A Dart package that utilizes annotations to extract metadata from models for Model Context Protocol (MCP) tools.

## What the package is about

`dart_mcp_toolkit` is a Dart package designed to streamline the definition of models representing MCP server tools and their input schemas. It leverages Dart's reflection capabilities (`dart:mirrors`) and custom annotations (`@MCPToolInput`, `@MCPToolProperty`) to allow developers to declare tool inputs and their properties directly within their Dart classes. This approach eliminates the need for manual schema creation and maintenance, promoting a more declarative and less error-prone way to define tools.

## Use Case of the package

This package is ideal for scenarios where you need to:
*   **Define callable tools declaratively:** Instead of manually constructing tool definitions with their input schemas, you can define a Dart model class that represents the tool's input using annotations.
    
    **Before `dart_mcp_toolkit` (Hardcoding Tool Definition):**
    ```dart
    Tool(
        name: 'readFile',
        description: 'Reads a file from the file system.',
        inputSchema: Schema.object(
          properties: {
            'path': Schema.string(description: 'The path to the file to read.'),
          },
        ),
      )
    ```

    **With `dart_mcp_toolkit` (Model-based Definition):**
    ```dart
    @MCPToolInput(
      toolName: 'readFile',
      toolDescription: 'Reads a file from the file system.',
    )
    class ReadFileTool {
      const ReadFileTool({required this.path});

      @MCPToolProperty(description: 'The path to the file to read.', isRequired: true)
      final String path;
    }
    ```
*   **Structure tool parameters:** Clearly define the input parameters for these tools, including their names, descriptions, and whether they are required, directly within your Dart models.
*   **Generate tool schemas automatically:** Automatically extract a structured schema (similar to JSON Schema) from your Dart models. This schema can then be used by external systems (like an MCP server) to understand and interact with your defined tools, facilitating dynamic tool invocation.
*   **Serialize schemas to JSON:** All generated schemas support JSON serialization via the `toJson()` method, making it easy to integrate with JSON-RPC or other JSON-based protocols.

## How to use / example

1.  **Add dependencies:**
    ```yaml
    dependencies:
      dart_mcp_toolkit: ^0.1.0 # Use the latest version
    ```

2.  **Define your tool inputs and properties** using the `@MCPToolInput` and `@MCPToolProperty` annotations:

    ```dart
    import 'package:dart_mcp_toolkit/mcp_toolkit.dart';

    @MCPToolInput(
      toolName: 'getCurrentWeather',
      toolDescription: 'Get the current weather in a given location',
    )
    class GetCurrentWeatherTool {
      const GetCurrentWeatherTool({required this.location, this.unit});

      @MCPToolProperty(description: 'The location to get the weather for', isRequired: true)
      final Location location;

      @MCPToolProperty(description: 'The unit of temperature to return')
      final TemperatureUnit? unit;
    }

    @MCPToolInput(
      toolName: 'getSpecialWeather',
      toolDescription: 'Get special weather for a given location',
    )
    class GetSpecialWeatherTool {
      const GetSpecialWeatherTool({required this.location, required this.date});

      @MCPToolProperty(description: 'The location to get the weather for', isRequired: true)
      final Location location;

      @MCPToolProperty(description: 'The date to get the special weather for', isRequired: true)
      final String date;
    }

   
    class Location {
      const Location({required this.city, this.country});

      @MCPToolProperty(description: 'The city name', isRequired: true)
      final String city;

      @MCPToolProperty(description: 'The country name')
      final String? country;
    }

    enum TemperatureUnit {
      celsius,
      fahrenheit,
    }
    ```

    **Note:** Nested classes like [`Location`](lib/src/models/callable_property_schema.dart) don't require the `@MCPToolInput` annotation - only the top-level tool input classes need it. Properties within nested classes are automatically extracted when annotated with `@MCPToolProperty`.


3.  **Initialize [`MCPModelToolMapper`](lib/src/mcp_model_tool_mapper.dart)** and retrieve your callable tools:

    ```dart
    void main() {
      // Initialize the mapper with your tool input classes
      final mapper = MCPModelToolMapper(
        toolInput: [
          GetCurrentWeatherTool,
          GetSpecialWeatherTool,
        ],
      )..initialize();

      // Retrieve a specific tool by name
      final getWeatherTool = mapper.callableToolByName('getCurrentWeather');
      if (getWeatherTool != null) {
        print('Tool Name: ${getWeatherTool.toolName}');
        print('Description: ${getWeatherTool.toolDescription}');
        
        // Access the input schema
        final schema = getWeatherTool.inputSchema;
        print('Properties: ${schema?.properties?.length}');
        
        // Serialize to JSON for MCP server integration
        final jsonSchema = schema?.toJson();
        print('JSON Schema: $jsonSchema');
      }

      // Or get all callable tools
      final allTools = mapper.callableTools;
      print('Total tools: ${allTools.length}');
      
      // Each tool can be serialized to JSON
      for (final tool in allTools) {
        final toolJson = {
          'name': tool.toolName,
          'description': tool.toolDescription,
          'inputSchema': tool.inputSchema?.toJson(),
        };
        print(toolJson);
      }
    }
    ```

## Additional Features

### Custom Property Names

You can specify custom names for properties using the `name` parameter in [`@MCPToolProperty`](lib/src/annotations/annotations.dart):

```dart
@MCPToolInput(toolName: 'customNaming', toolDescription: 'Example of custom naming')
class CustomNamingTool {
  const CustomNamingTool({required this.internalName});

  @MCPToolProperty(
    name: 'external_name',  // This will be used in the schema
    description: 'Custom named property',
    isRequired: true,
  )
  final String internalName;
}
```

### Nested Objects and Lists

The toolkit supports complex nested structures including objects within objects and lists of objects:

```dart
@MCPToolInput(toolName: 'complexData', toolDescription: 'Handle complex nested data')
class ComplexDataTool {
  const ComplexDataTool({required this.items});

  @MCPToolProperty(description: 'List of data objects', isRequired: true)
  final List<DataObject> items;
}

class DataObject {
  const DataObject({required this.id, this.metadata});

  @MCPToolProperty(description: 'Unique identifier', isRequired: true)
  final String id;

  @MCPToolProperty(description: 'Optional metadata')
  final Map<String, dynamic>? metadata;
}
```

### Enum Support

The toolkit handles Dart enums, including those with methods and variables:

```dart
enum Priority {
  low,
  medium,
  high;
  
  String get displayName => name.toUpperCase();
}

@MCPToolInput(toolName: 'taskTool')
class TaskTool {
  const TaskTool({required this.priority});

  @MCPToolProperty(description: 'Task priority', isRequired: true)
  final Priority priority;
}
```

### JSON Schema Serialization

All schema types implement a [`toJson()`](lib/src/models/callable_property_schema.dart) method for easy serialization:

```dart
final mapper = MCPModelToolMapper(toolInput: [GetCurrentWeatherTool])..initialize();
final tool = mapper.callableToolByName('getCurrentWeather');

// Serialize the entire input schema
final schemaJson = tool?.inputSchema?.toJson();
// Returns:
// {
//   'type': 'object',
//   'properties': {
//     'location': { /* location schema */ },
//     'unit': { /* unit schema */ }
//   },
//   'required': ['location']
// }
```

## Schema Types Supported

The `dart_mcp_toolkit` generates schemas that are compatible with JSON Schema, commonly used with JSON-RPC 2.0 and MCP for describing parameters.

| `dart_mcp_toolkit` Schema Type | Corresponding JSON Schema Type | Description | Dart Type Examples |
| :------------------------ | :----------------------------- | :---------- | :----------------- |
| [`StringPropertySchema`](lib/src/models/callable_property_schema.dart) | `string` | Represents a string value | `String` |
| [`BooleanPropertySchema`](lib/src/models/callable_property_schema.dart) | `boolean` | Represents a boolean value | `bool` |
| [`NumberPropertySchema`](lib/src/models/callable_property_schema.dart) | `number` | Represents a numeric value (integers or floating-point) | `num`, `double` |
| [`IntPropertySchema`](lib/src/models/callable_property_schema.dart) | `integer` | Represents an integer value | `int` |
| [`ListPropertySchema`](lib/src/models/callable_property_schema.dart) | `array` | Represents an ordered list of values | `List<T>` |
| [`EnumPropertySchema`](lib/src/models/callable_property_schema.dart) | `string` with `enum` | Represents a value from a predefined set | Any Dart `enum` |
| [`ObjectPropertySchema`](lib/src/models/callable_property_schema.dart) | `object` | Represents a structured object with named properties | Custom classes |
| [`NullPropertySchema`](lib/src/models/callable_property_schema.dart) | `null` | Represents a null value | - |
| [`InvalidPropertySchema`](lib/src/models/callable_property_schema.dart) | - | Represents an unsupported or invalid type | Unsupported types |


## Limitations

Due to the use of `dart:mirrors`, the package has some limitations:

*   **No support for Record types:** The package does not currently support extracting metadata from Dart `Record` types due to limitations with `dart:mirrors`. Using record types will result in an [`InvalidSchema`](lib/src/models/callable_property_schema.dart).
    ```dart
    @MCPToolProperty()
    final ({String a, int b}) record;  // Not supported - will generate InvalidSchema
    ```

*   **`isRequired` for named parameters:** Due to a known limitation in `dart:mirrors`, the `paramMirror.isOptional` property always returns `true` for named parameters. Therefore, you must explicitly set `isRequired` in the [`@MCPToolProperty`](lib/src/annotations/annotations.dart) annotation:
    ```dart
    @MCPToolProperty(isRequired: true)  // Must explicitly set this
    final String requiredParam;
    ```

*   **Limited dynamic type handling:** The package may return an [`InvalidSchema`](lib/src/models/callable_property_schema.dart) for complex or unhandled Dart types that do not have a direct mapping to the supported schema types.

*   **Reflection dependency:** The package requires `dart:mirrors`, which is not available in Flutter or web applications. It's designed for use in Dart server-side applications only.

## API Reference

### Core Classes

- [`MCPModelToolMapper`](lib/src/mcp_model_tool_mapper.dart) - Main class for extracting tool metadata
  - [`initialize()`](lib/src/mcp_model_tool_mapper.dart:15) - Initialize the mapper and extract all tool definitions
  - [`callableToolByName(String)`](lib/src/mcp_model_tool_mapper.dart:23) - Get a specific tool by name
  - [`callableTools`](lib/src/mcp_model_tool_mapper.dart:25) - Get all extracted tools

- [`CallableTool`](lib/src/models/callable_tool.dart) - Represents a tool with its metadata
  - `toolName` - The name of the tool
  - `toolDescription` - Optional description
  - `inputSchema` - The input schema as an [`ObjectSchema`](lib/src/models/callable_property_schema.dart)

### Annotations

- [`@MCPToolInput`](lib/src/annotations/annotations.dart) - Marks a class as a tool input definition
  - `toolName` (required) - The name of the tool
  - `toolDescription` (optional) - Description of what the tool does

- [`@MCPToolProperty`](lib/src/annotations/annotations.dart) - Marks a field as a tool property
  - `description` (optional) - Description of the property
  - `isRequired` (optional) - Whether this property is required
  - `name` (optional) - Custom name for the property in the schema

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the BSD-3-Clause License - see the LICENSE file for details.
