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
  const Message(this.name, this.properties);

  final String name;
  final List<MessageField> properties;
}

class Endpoint {
  const Endpoint(this.response, this.request, this.name);

  final Message? response;
  final Message? request;
  final String name;
}

class Service {
  const Service(this.name, this.endpoints);

  final List<Endpoint> endpoints;
  final String name;
}

class Schema {
  const Schema(this.enums, this.messages, this.services);

  final List<Enum> enums;
  final List<Message> messages;
  final List<Service> services;
}
