import 'package:patrol_finders/src/custom_finders/patrol_tester.dart';

/// Makes it possible to retrieve a name that this [Symbol] was created with.
extension SymbolName on Symbol {
  /// Returns the name that this [Symbol] was created with.
  ///
  /// It's kinda hacky, but works well. Might require adjustements to work on
  /// the web though.
  String get name {
    final symbol = toString();
    return symbol.substring(8, symbol.length - 2);
  }
}

/// Returns correct [settlePolicy], regardless which settling argument was set
SettlePolicy? chooseSettlePolicy({
  bool? andSettle,
  SettlePolicy? settlePolicy,
}) {
  SettlePolicy? settle;
  if (andSettle == null) {
    settle = settlePolicy;
  } else {
    if (andSettle) {
      settle = SettlePolicy.settle;
    } else {
      settle = SettlePolicy.noSettle;
    }
  }
  return settle;
}
