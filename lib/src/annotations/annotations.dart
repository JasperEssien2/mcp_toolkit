import 'package:equatable/equatable.dart';

class MCPToolInput extends Equatable {
  const MCPToolInput({required this.toolName, required this.toolDescription});

  final String toolName;
  final String toolDescription;

  @override
  List<Object> get props => [toolName, toolDescription];
}

class MCPToolProperty extends Equatable {
  const MCPToolProperty({
    required this.description,
    this.isRequired = true,
    this.name,
  });

  final String description;
  final bool isRequired;
  final String? name;

  @override
  List<Object?> get props => [description, isRequired, name];
}
