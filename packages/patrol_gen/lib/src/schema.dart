class Enum {
  const Enum(this.name, this.fields);

  final String name;
  final List<String> fields;
}

sealed class MessageFieldType {}

class OrdinaryFieldType implements MessageFieldType {
  const OrdinaryFieldType({required this.type});

  final String type;
}

class ListFieldType implements MessageFieldType {
  const ListFieldType({required this.type});

  final String type;
}

class MapFieldType implements MessageFieldType {
  const MapFieldType({required this.keyType, required this.valueType});

  final String keyType;
  final String valueType;
}

class MessageField {
  const MessageField({
    required this.name,
    required this.type,
    required this.isOptional,
  });

  final bool isOptional;
  final String name;
  final MessageFieldType type;
}

class Message {
  const Message(this.name, this.fields);

  final String name;
  final List<MessageField> fields;
}

class Endpoint {
  const Endpoint(this.response, this.request, this.name);

  final Message? response;
  final Message? request;
  final String name;
}

class ServiceGenConfig {
  const ServiceGenConfig({
    required this.needsClient,
    required this.needsServer,
  });

  final bool needsClient;
  final bool needsServer;
}

class Service {
  const Service(this.name, this.ios, this.dart, this.android, this.endpoints);

  final List<Endpoint> endpoints;
  final String name;
  final ServiceGenConfig ios;
  final ServiceGenConfig dart;
  final ServiceGenConfig android;
}

class Schema {
  const Schema(this.enums, this.messages, this.services);

  final List<Enum> enums;
  final List<Message> messages;
  final List<Service> services;
}
