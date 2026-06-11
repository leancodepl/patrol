# Patrol bundles Deque's `axeDevToolsXCUI` framework so accessibility scanning
# works out of the box. That framework links against `XCUIAutomation.framework`,
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
#   post_install do |installer|
#     patrol_post_install(installer)
#   end
AXE_FRAMEWORK_NAME = 'axeDevToolsXCUI'.freeze

def patrol_post_install(installer)
  installer.aggregate_targets.each do |aggregate_target|
    # UI test targets run in the XCUITest runtime where `XCUIAutomation` is
    # available, so axe must stay linked and embedded there.
    next if patrol_ui_test_target?(aggregate_target)

    support_files_dir = aggregate_target.support_files_dir.to_s
    label = aggregate_target.label

    patrol_prune_axe_framework_paths(aggregate_target)
    patrol_strip_axe_from_embed(support_files_dir, label)
    patrol_weak_link_axe(support_files_dir, label)
  end
end

# Removes axe from the aggregate target's resolved framework lists so the
# input/output file lists CocoaPods regenerates during user-project integration
# (which happens after this hook) also exclude it, keeping them consistent with
# the patched embed script.
def patrol_prune_axe_framework_paths(aggregate_target)
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

def patrol_ui_test_target?(aggregate_target)
  aggregate_target.user_targets.any? do |native_target|
    native_target.respond_to?(:product_type) &&
      native_target.product_type == 'com.apple.product-type.bundle.ui-testing'
  end
end

# Removes axe from the framework copy script and the matching input/output file
# lists so it is never copied into the app bundle.
def patrol_strip_axe_from_embed(support_files_dir, label)
  Dir.glob(File.join(support_files_dir, "#{label}-frameworks*")).each do |path|
    original = File.read(path)
    filtered = original.each_line.reject { |line| line.include?(AXE_FRAMEWORK_NAME) }.join
    File.write(path, filtered) unless filtered == original
  end
end

# Rewrites the strong `-framework "axeDevToolsXCUI"` link flag to a weak one so
# the app process doesn't abort when the framework is absent at runtime.
def patrol_weak_link_axe(support_files_dir, label)
  Dir.glob(File.join(support_files_dir, "#{label}.*.xcconfig")).each do |path|
    original = File.read(path)
    updated = original.gsub(
      %{-framework "#{AXE_FRAMEWORK_NAME}"},
      %{-weak_framework "#{AXE_FRAMEWORK_NAME}"},
    )
    File.write(path, updated) unless updated == original
  end
end
