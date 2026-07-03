# patrol_axe bundles Deque's `axeDevToolsXCUI` framework so accessibility scanning
# works in Patrol UI tests. That framework links against `XCUIAutomation.framework`,
# which only exists in the UI test (XCUITest) runtime — never in a regular app
# process. If axe ends up embedded in the app, dyld tries to load it at launch
# and aborts with:
#
#   Library not loaded: @rpath/XCUIAutomation.framework/XCUIAutomation
#   Referenced from: .../Runner.app/Frameworks/axeDevToolsXCUI.framework/...
#
# CocoaPods can't scope a vendored framework to a single consumer, so this helper
# fixes it up after integration: axe is weak-linked from the app (so dyld tolerates
# its absence at launch) and embedded only into the UI test bundle, where the
# XCUITest runtime provides `XCUIAutomation`.
#
# Usage — call it from your Podfile's `post_install` hook:
#
#   require_relative '../patrol_axe/darwin/patrol_axe_post_install'
#   post_install do |installer|
#     flutter_additional_ios_build_settings(installer)
#     patrol_axe_post_install(installer)
#   end
AXE_FRAMEWORK_NAME = 'axeDevToolsXCUI'.freeze

def patrol_axe_post_install(installer)
  installer.aggregate_targets.each do |aggregate_target|
    next if patrol_axe_ui_test_target?(aggregate_target)

    support_files_dir = aggregate_target.support_files_dir.to_s
    label = aggregate_target.label

    patrol_axe_prune_framework_paths(aggregate_target)
    patrol_axe_strip_from_embed(support_files_dir, label)
    patrol_axe_weak_link(support_files_dir, label)
  end
end

def patrol_axe_ui_test_target?(aggregate_target)
  aggregate_target.user_targets.any? do |native_target|
    native_target.respond_to?(:product_type) &&
      native_target.product_type == 'com.apple.product-type.bundle.ui-testing'
  end
end

def patrol_axe_prune_framework_paths(aggregate_target)
  axe_match = ->(path) { path.to_s.include?(AXE_FRAMEWORK_NAME) }

  if aggregate_target.respond_to?(:framework_paths_by_config)
    aggregate_target.framework_paths_by_config.each_value do |framework_paths|
      framework_paths.reject! { |framework_path| axe_match.call(framework_path.source_path) }
    end
  end

  if aggregate_target.respond_to?(:xcframeworks_by_config)
    aggregate_target.xcframeworks_by_config.each_value do |xcframeworks|
      xcframeworks.reject! { |xcframework| axe_match.call(xcframework.path) }
    end
  end
end

def patrol_axe_strip_from_embed(support_files_dir, label)
  Dir.glob(File.join(support_files_dir, "#{label}-frameworks*")).each do |path|
    original = File.read(path)
    filtered = original.each_line.reject { |line| line.include?(AXE_FRAMEWORK_NAME) }.join
    File.write(path, filtered) unless filtered == original
  end
end

def patrol_axe_weak_link(support_files_dir, label)
  Dir.glob(File.join(support_files_dir, "#{label}.*.xcconfig")).each do |path|
    original = File.read(path)
    updated = original.gsub(
      %{-framework "#{AXE_FRAMEWORK_NAME}"},
      %{-weak_framework "#{AXE_FRAMEWORK_NAME}"},
    )
    File.write(path, updated) unless updated == original
  end
end
