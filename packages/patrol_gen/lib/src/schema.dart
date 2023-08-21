class Enum {
  const Enum(this.name, this.fields);

  final String name;
  final List<String> fields;
}

class MessageField {
  const MessageField(this.isOptional, this.name, this.type, this.isList);

  final bool isOptional;
  final bool isList;
  final String name;
  final String type;
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
  const ServiceGenConfig(this.needsClient, this.needsServer);

  final bool needsClient;
  final bool needsServer;
}

class Service {
  const Service(this.name, this.ios, this.dart, this.endpoints);

  final List<Endpoint> endpoints;
  final String name;
  final ServiceGenConfig ios;
  final ServiceGenConfig dart;
}

class Schema {
  const Schema(this.enums, this.messages, this.services);

  final List<Enum> enums;
  final List<Message> messages;
  final List<Service> services;
}
