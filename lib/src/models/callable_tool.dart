import 'package:dart_mcp_toolkit/src/models/callable_property_schema.dart';
import 'package:equatable/equatable.dart';

final class CallableTool extends Equatable {
  const CallableTool({required this.toolName, this.toolDescription, this.inputSchema});

  final String toolName;
  final String? toolDescription;
  final ObjectSchema? inputSchema;

  @override
  List<Object?> get props => [toolName, toolDescription, inputSchema];
}
