import 'package:equatable/equatable.dart';

// TODO(jasperessien): Apply error lint to avoid using for invalid cases
class MCPToolInput extends Equatable {
  const MCPToolInput({required this.toolName, this.toolDescription});

  final String toolName;
  final String? toolDescription;

  @override
  List<Object?> get props => [toolName, toolDescription];
}

// TODO(jasperessien): dart:mirror `paramMirror.isOptional` always returns true for named parameters
class MCPToolProperty extends Equatable {
  const MCPToolProperty({this.description, this.isRequired, this.name});

  final String? description;
  final bool? isRequired;
  final String? name;

  @override
  List<Object?> get props => [description, isRequired, name];
}
