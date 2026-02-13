/// Standard exit codes for the chase CLI.
abstract final class ExitCodes {
  static const success = 0;
  static const usage = 64;
  static const software = 70;
  static const config = 78;
  static const noConfig = 1;
  static const validationFailed = 2;
  static const agentFailed = 3;
  static const marathonFailed = 4;
  static const gitFailed = 5;
  static const budgetExceeded = 6;
}
