# mcp_toolkit

A tool that utilizes annotation and extracts metadata from models for mcp tools.

## What the package is about

`mcp_toolkit` is a Dart package designed to streamline the definition of models representing mcp-server tools and their input schema. It leverages Dart's reflection capabilities (`dart:mirrors`) and custom annotations (`@MCPToolInput`, `@MCPToolProperty`) to allow developers to declare tool inputs and their properties directly within their Dart classes. This approach eliminates the need for manual schema creation and maintenance, promoting a more declarative and less error-prone way to define tools.

## Use Case of the package

This package is ideal for scenarios where you need to:
*   **Define callable tools declaratively:** Instead of manually constructing tool definitions with their input schemas, you can define a Dart model class that represents the tool's input.
    
    **Before `mcp_toolkit` (Hardcoding Tool Definition):**
    ```dart
    Tool(
        name: 'readFile',
        description: 'Reads a file from the file system.',
        inputSchema: Schema.object(
          properties: {
            'path': Schema.string(description: 'The path to the file to read.'),
          },
        ),
        annotations: ToolAnnotations(readOnlyHint: true),
      )
    ```

    **With `mcp_toolkit` (Model-based Definition):**
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
*   **Generate tool schemas automatically:** Automatically extract a structured schema (similar to JSON Schema) from your Dart models. This schema can then be used by external systems (like an `mcp_server`) to understand and interact with your defined tools, facilitating dynamic tool invocation.

## How to use / example

1.  **Add dependencies:**
    ```yaml
    dependencies:
      mcp_toolkit: ^0.1.0 # Use the latest version
    ```

2.  **Define your tool inputs and properties** using the `@MCPToolInput` and `@MCPToolProperty` annotations:

    ```dart
    import 'package:mcp_toolkit/mcp_toolkit.dart';

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

3.  **Initialize `MCPModelToolMapper`** and retrieve your callable tools:

    ```dart
    void main() {
      final mapper = MCPModelToolMapper(
        toolInput: [
          GetCurrentWeatherTool,
          GetSpecialWeatherTool,
        ],
      )..initialize();

      final getWeatherTool = mapper.callableToolByName('getCurrentWeather');
      // 'getWeatherTool' now contains the extracted metadata:
      // getWeatherTool.toolName: 'getCurrentWeather'
      // getWeatherTool.toolDescription: 'Get the current weather in a given location'
      // getWeatherTool.properties: List<CallablePropertySchema> representing 'location' and 'unit'

      final callableTools = mapper.callableTools;
      // List of callable tools schema definition
    }

    ```

## Schema types supported by the tool compared with JSON-RPC 2.0

The `mcp_toolkit` generates schemas that are conceptually similar to JSON Schema, which is commonly used with JSON-RPC 2.0 for describing parameters.

| `mcp_toolkit` Schema Type | Corresponding JSON Schema Type | Description                                                              |
| :------------------------ | :----------------------------- | :----------------------------------------------------------------------- |
| `StringSchema`            | `string`                       | Represents a string value.                                               |
| `BooleanSchema`           | `boolean`                      | Represents a boolean value (`true` or `false`).                          |
| `NumberSchema`            | `number`                       | Represents a numeric value (integers or floating-point numbers).         |
| `IntSchema`               | `integer`                      | Represents an integer value.                                             |
| `ListSchema`              | `array`                        | Represents an ordered list of values. The `type` property describes the elements. |
| `EnumSchema`              | `enum`                         | Represents a value that must be one of a predefined set of options.      |
| `ObjectSchema`            | `object`                       | Represents a structured object with named properties.                    |


## Limitations of the package

*   **No support for Record types:** The package does not currently support extracting metadata from Dart `Record` types due to limitations with `dart:mirrors`.
*   **`isRequired` for named parameters:** Due to a known limitation in `dart:mirrors`, the `paramMirror.isOptional` property always returns `true` for named parameters. This means the `isRequired` property in `@MCPToolProperty` might not accurately reflect the optionality of named parameters as intended by Dart's null-safety.
*   **Limited dynamic type handling:** The package may return an `InvalidSchema` for complex or unhandled Dart types that do not have a direct mapping to the supported schema types.
*   **No explicit `null` type:** While properties can be marked as not required (`isRequired: false`), there isn't a distinct `NullSchema` to represent a nullable type explicitly in the generated schema (e.g., `type: ["string", "null"]` in JSON Schema).
