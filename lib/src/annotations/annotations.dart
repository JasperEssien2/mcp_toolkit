import 'package:equatable/equatable.dart';

class MCPToolInput extends Equatable {
  const MCPToolInput({this.toolName, this.toolDescription});

  final String? toolName;
  final String? toolDescription;

  @override
  List<Object?> get props => [toolName, toolDescription];
}

class MCPToolProperty extends Equatable {
  const MCPToolProperty({this.description, this.isRequired, this.name});

  final String? description;
  final bool? isRequired;
  final String? name;

  @override
  List<Object?> get props => [description, isRequired, name];
}
