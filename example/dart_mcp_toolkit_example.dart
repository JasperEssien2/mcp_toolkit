import 'dart:developer' as logger;

import 'package:dart_mcp_toolkit/dart_mcp_toolkit.dart';

void main() {
  logger.log('=== MCP Toolkit Example ===\n');

  // Initialize the mapper with all tool input classes
  final mapper = MCPModelToolMapper(
    toolInput: [GetCurrentWeatherTool, GetSpecialWeatherTool, CustomNamingTool, ComplexDataTool, TaskTool],
  )..initialize();

  logger.log('Total tools registered: ${mapper.callableTools.length}\n');

  // Example 1: Retrieve and inspect a specific tool
  logger.log('--- Example 1: Get Current Weather Tool ---');
  final getWeatherTool = mapper.callableToolByName('getCurrentWeather');
  if (getWeatherTool != null) {
    logger.log('Tool Name: ${getWeatherTool.toolName}');
    logger.log('Description: ${getWeatherTool.toolDescription}');

    // Access the input schema
    final schema = getWeatherTool.inputSchema;
    logger.log('Properties count: ${schema?.properties?.length}');
    logger.log('Required properties: ${schema?.requiredProperties}');

    // Serialize to JSON for MCP server integration
    final jsonSchema = schema?.toJson();
    logger.log('JSON Schema: $jsonSchema\n');
  }

  // Example 2: Inspect custom naming tool
  logger.log('--- Example 2: Custom Naming Tool ---');

  if (mapper.callableToolByName('customNaming') case final tool?) {
    logger.log('Tool Name: ${tool.toolName}');
    final jsonSchema = tool.inputSchema?.toJson();
    logger.log('JSON Schema: $jsonSchema\n');
  }

  // Example 3: List all tools with their schemas
  logger.log('--- Example 3: All Tools Overview ---');
  for (final tool in mapper.callableTools) {
    logger.log('${tool.toolName}:');
    logger.log('  Description: ${tool.toolDescription}');
    final propertyNames = tool.inputSchema?.properties?.map((p) => p.name).join(', ') ?? 'none';
    logger.log('  Schema properties: $propertyNames');
    logger.log('  Required fields: ${tool.inputSchema?.requiredProperties?.join(', ') ?? 'none'}');
    logger.log('');
  }

  // Example 4: Demonstrate nested object structure
  logger.log('--- Example 4: Complex Data Tool Structure ---');

  if (mapper.callableToolByName('complexData') case final complexTool?) {
    final schema = complexTool.inputSchema;
    final itemsProperty = schema?.properties?.firstWhere(
      (p) => p.name == 'items',
      orElse: () => const InvalidSchema(name: 'not_found', error: 'Not found'),
    );
    logger.log('Tool: ${complexTool.toolName}');
    logger.log('Items property type: ${itemsProperty?.runtimeType}');
    if (itemsProperty case ListSchema(:final type)) {
      logger.log('Items contain: ${itemsProperty.jsonType}');
      if (type case ObjectSchema(:final properties?)) {
        final objectPropertyNames = properties.map((p) => p.name).join(', ');
        logger.log('Object properties: $objectPropertyNames');
      }
    }
    logger.log('');
  }

  // Example 5: Show enum handling
  logger.log('--- Example 5: Task Tool with Enum ---');

  if (mapper.callableToolByName('taskTool') case CallableTool(:final toolName, :final inputSchema?)) {
    final priorityProperty = inputSchema.properties?.firstWhere(
      (p) => p.name == 'priority',
      orElse: () => const InvalidSchema(name: 'not_found', error: 'Not found'),
    );
    logger.log('Tool: $toolName');
    logger.log('Priority property type: ${priorityProperty?.runtimeType}');
    if (priorityProperty is EnumSchema) {
      logger.log('Enum values: ${priorityProperty.options}');
    }
    logger.log('Full JSON: ${inputSchema.toJson()}');
  }

  logger.log('\n=== Example Complete ===');
}

// Example 1: Basic tool with simple properties
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

// Example 2: Tool with date parameter
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

// Example 3: Tool with custom property names
@MCPToolInput(
  toolName: 'customNaming',
  toolDescription: 'Example of custom naming',
)
class CustomNamingTool {
  const CustomNamingTool({required this.internalName, required this.configPath});

  @MCPToolProperty(
    name: 'external_name',
    description: 'Custom named property',
    isRequired: true,
  )
  final String internalName;

  @MCPToolProperty(
    name: 'config_file_path',
    description: 'Path to configuration file',
    isRequired: true,
  )
  final String configPath;
}

// Example 4: Tool with complex nested data and lists
@MCPToolInput(
  toolName: 'complexData',
  toolDescription: 'Handle complex nested data',
)
class ComplexDataTool {
  const ComplexDataTool({required this.items, this.tags});

  @MCPToolProperty(description: 'List of data objects', isRequired: true)
  final List<DataObject> items;

  @MCPToolProperty(description: 'Optional tags')
  final List<String>? tags;
}

// Example 5: Task tool with priority enum
@MCPToolInput(
  toolName: 'taskTool',
  toolDescription: 'Create or manage a task',
)
class TaskTool {
  const TaskTool({required this.title, required this.priority});

  @MCPToolProperty(description: 'The task title', isRequired: true)
  final String title;

  @MCPToolProperty(description: 'Task priority', isRequired: true)
  final Priority priority;
}

// Nested class: Location object
class Location {
  const Location({required this.city, this.country});

  @MCPToolProperty(description: 'The city name', isRequired: true)
  final String city;

  @MCPToolProperty(description: 'The country name')
  final String? country;
}

// Nested class: DataObject for complex example
class DataObject {
  const DataObject({required this.id, this.metadata, this.value});

  @MCPToolProperty(description: 'Unique identifier', isRequired: true)
  final String id;

  @MCPToolProperty(description: 'Optional metadata')
  final Map<String, dynamic>? metadata;

  @MCPToolProperty(description: 'Numeric value')
  final double? value;
}

// Enum: TemperatureUnit
enum TemperatureUnit {
  celsius,
  fahrenheit,
}

// Enum with methods and variables
enum Priority {
  low,
  medium,
  high;

  String get displayName => name.toUpperCase();
}
