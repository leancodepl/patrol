import 'package:mason_logger/mason_logger.dart';

Future<void> main() async {
  // Use the various APIs to log to stdout.
  final logger = Logger(
    // Specify a log level (defaults to Level.info).
    level: Level.verbose,
  )
    ..info('info')
    ..alert('alert')
    ..err('error')
    ..success('success')
    ..warn('warning')
    ..detail('detail');

  // Prompt for user input.
  final favoriteAnimal = logger.prompt(
    'What is your favorite animal?',
    defaultValue: '🐈',
  );

  /// Ask user to choose an option.
  final favoriteColor = logger.chooseOne(
    'What is your favorite color?',
    choices: ['red', 'green', 'blue'],
    defaultValue: 'blue',
  );

  /// Ask user to choose zero or more options.
  final desserts = logger.chooseAny(
    'Which desserts do you like?',
    choices: ['🍦', '🍪', '🍩'],
  );

  // Ask for user confirmation.
  final likesCats = logger.confirm('Do you like cats?', defaultValue: true);

  // Show a progress message while performing an asynchronous operation.
  final progress = logger.progress('Calculating');
  await Future<void>.delayed(const Duration(seconds: 1));

  // Provide an update.
  progress.update('Almost done');
  await Future<void>.delayed(const Duration(seconds: 1));

  // Show a completion message when the asynchronous operation has completed.
  progress.complete('Done!');

  // Use the user provided input.
  logger
    ..info('Your favorite animal is a $favoriteAnimal!')
    ..alert(likesCats ? 'You are a cat person!' : 'You are not a cat person.');

  // Show hyperlinks using the link API.
  final repoLink = link(
    message: 'GitHub Repository',
    uri: Uri.parse('https://github.com/felangel/mason'),
  );
  logger.info('To learn more, visit the $repoLink.');
}
