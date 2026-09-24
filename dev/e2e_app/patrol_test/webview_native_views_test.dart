import 'package:plaid_flutter/plaid_flutter.dart';

import 'common.dart';

void main() {
  Future<List<String>> linkContent(
    PatrolIntegrationTester $, {
    required bool skipNodesNotVisibleToUser,
  }) async {
    await createApp($);
    await $.platform.mobile.openUrl('patrolflag://set?value=$skipNodesNotVisibleToUser');

    PlaidLink.create(
      configuration: LinkTokenConfiguration(
        token: 'link-sandbox-00000000-0000-0000-0000-000000000000',
      ),
    );
    PlaidLink.open();
    await Future<void>.delayed(const Duration(seconds: 10));

    await $.platform.android.getNativeViews(
      AndroidSelector(className: 'android.widget.Button'),
    );

    final content = <String>[];
    void walk(AndroidNativeView node, {required bool inWebView}) {
      final isWebView = (node.className ?? '').contains('WebView');
      // Skip nested WebView nodes; they carry the view's own title, not content.
      if (inWebView && !isWebView) {
        final label = (node.text ?? node.contentDescription ?? '').trim();
        if (label.isNotEmpty) content.add(label);
      }
      for (final child in node.children) {
        walk(child, inWebView: inWebView || isWebView);
      }
    }

    for (final root in (await $.platform.android.getNativeViews(null)).roots) {
      walk(root, inWebView: false);
    }

    $.log(
      'skipNodesNotVisibleToUser=$skipNodesNotVisibleToUser -> '
      '${content.length} node(s) under the WebView: $content',
    );
    return content;
  }

  patrol(
    'getNativeViews returns SDK webview content (skipNodesNotVisibleToUser = true)',
    ($) async {
      final content = await linkContent($, skipNodesNotVisibleToUser: true);
      expect(content, isNotEmpty, reason: 'no Link content in the tree');
    },
    tags: ['webview', 'android'],
  );

  patrol(
    'getNativeViews returns SDK webview content (skipNodesNotVisibleToUser = false)',
    ($) async {
      final content = await linkContent($, skipNodesNotVisibleToUser: false);
      expect(content, isNotEmpty, reason: 'no Link content in the tree');
    },
    tags: ['webview', 'android'],
  );
}
