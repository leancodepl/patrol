part of 'entry.dart';

@JsonSerializable()
class ConfigEntry extends Entry {
  ConfigEntry({
    required this.config,
    DateTime? timestamp,
  }) : super(
          timestamp: timestamp ?? DateTime.now(),
          type: EntryType.config,
        );

  @override
  factory ConfigEntry.fromJson(Map<String, dynamic> json) =>
      _$ConfigEntryFromJson(json);

  final Map<String, dynamic> config;

  @override
  Map<String, dynamic> toJson() => _$ConfigEntryToJson(this);

  @override
  String pretty() => config.toString();

  @override
  String toString() => 'ConfigEntry(${toJson()})';

  @override
  List<Object?> get props => [config, timestamp, type];
}
