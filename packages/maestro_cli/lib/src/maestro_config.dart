class MaestroConfig {
  const MaestroConfig({
    required this.bootstrapConfig,
    required this.driveConfig,
  });

  final BootstrapConfig bootstrapConfig;
  final DriveConfig driveConfig;
}

class BootstrapConfig {
  const BootstrapConfig({required this.artifactPath});

  /// Directory to which artifacts will be downloaded.
  ///
  /// If the directory does not exist, it will be created.
  final String artifactPath;
}

class DriveConfig {
  const DriveConfig({
    required this.host,
    required this.port,
    required this.target,
    required this.driver,
  });

  final String host;
  final int port;
  final String target;
  final String driver;
}
