import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:platform/platform.dart';

FileSystem get fs => const LocalFileSystem();

Platform get platform => const LocalPlatform();
