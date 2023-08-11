class Enum {
  const Enum(this.name, this.fields);

  final String name;
  final List<String> fields;
}

class MessageField {
  const MessageField(this.optional, this.name, this.type);

  final bool optional;
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
  const Service(this.name, this.swift, this.dart, this.endpoints);

  final List<Endpoint> endpoints;
  final String name;
  final ServiceGenConfig swift;
  final ServiceGenConfig dart;
}

class Schema {
  const Schema(this.enums, this.messages, this.services);

  final List<Enum> enums;
  final List<Message> messages;
  final List<Service> services;
}