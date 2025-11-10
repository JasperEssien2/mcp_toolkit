import 'package:equatable/equatable.dart';
import 'package:mcp_toolkit/src/models/callable_property_schema.dart';

class CallableTool extends Equatable {
  const CallableTool({required this.toolName, required this.properties, this.toolDescription});

  final String toolName;
  final List<CallablePropertySchema> properties;

  final String? toolDescription;

  @override
  List<Object?> get props => [toolName, toolDescription, properties];
}
