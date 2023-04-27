class RuntimeTestsExample: ParametrizedTestCase {
  
  /// This is our parametrized method. For this example it just print out parameter value
  func p(_ s: String) {
    print("Magic: \(s)")
    XCTAssertTrue(true)
  }
  
  override class func _qck_testMethodSelectors() -> [_QuickSelectorWrapper] {
    /// For this example we create 3 runtime tests "test_a", "test_b" and "test_c" with corresponding parameter
    return ["a", "b", "c"].map { parameter in
      /// first we wrap our test method in block that takes TestCase instance
      let block: @convention(block) (RuntimeTestsExample) -> Void = { $0.p(parameter) }
      /// with help of ObjC runtime we add new test method to class
      let implementation = imp_implementationWithBlock(block)
      let selectorName = "test_\(parameter)"
      let selector = NSSelectorFromString(selectorName)
      class_addMethod(self, selector, implementation, "v@:")
      /// and return wrapped selector on new created method
      return _QuickSelectorWrapper(selector: selector)
    }
  }
}
