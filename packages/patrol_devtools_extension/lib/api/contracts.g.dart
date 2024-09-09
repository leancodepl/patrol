// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contracts.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DartGroupEntry _$DartGroupEntryFromJson(Map<String, dynamic> json) =>
    DartGroupEntry(
      name: json['name'] as String,
      type: $enumDecode(_$GroupEntryTypeEnumMap, json['type']),
      entries: (json['entries'] as List<dynamic>)
          .map((e) => DartGroupEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      skip: json['skip'] as bool,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$DartGroupEntryToJson(DartGroupEntry instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': _$GroupEntryTypeEnumMap[instance.type]!,
      'entries': instance.entries,
      'skip': instance.skip,
      'tags': instance.tags,
    };

const _$GroupEntryTypeEnumMap = {
  GroupEntryType.group: 'group',
  GroupEntryType.test: 'test',
};

ListDartTestsResponse _$ListDartTestsResponseFromJson(
        Map<String, dynamic> json) =>
    ListDartTestsResponse(
      group: DartGroupEntry.fromJson(json['group'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ListDartTestsResponseToJson(
        ListDartTestsResponse instance) =>
    <String, dynamic>{
      'group': instance.group,
    };

RunDartTestRequest _$RunDartTestRequestFromJson(Map<String, dynamic> json) =>
    RunDartTestRequest(
      name: json['name'] as String,
    );

Map<String, dynamic> _$RunDartTestRequestToJson(RunDartTestRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
    };

RunDartTestResponse _$RunDartTestResponseFromJson(Map<String, dynamic> json) =>
    RunDartTestResponse(
      result: $enumDecode(_$RunDartTestResponseResultEnumMap, json['result']),
      details: json['details'] as String?,
    );

Map<String, dynamic> _$RunDartTestResponseToJson(
        RunDartTestResponse instance) =>
    <String, dynamic>{
      'result': _$RunDartTestResponseResultEnumMap[instance.result]!,
      'details': instance.details,
    };

const _$RunDartTestResponseResultEnumMap = {
  RunDartTestResponseResult.success: 'success',
  RunDartTestResponseResult.skipped: 'skipped',
  RunDartTestResponseResult.failure: 'failure',
};

ConfigureRequest _$ConfigureRequestFromJson(Map<String, dynamic> json) =>
    ConfigureRequest(
      findTimeoutMillis: (json['findTimeoutMillis'] as num).toInt(),
    );

Map<String, dynamic> _$ConfigureRequestToJson(ConfigureRequest instance) =>
    <String, dynamic>{
      'findTimeoutMillis': instance.findTimeoutMillis,
    };

OpenAppRequest _$OpenAppRequestFromJson(Map<String, dynamic> json) =>
    OpenAppRequest(
      appId: json['appId'] as String,
    );

Map<String, dynamic> _$OpenAppRequestToJson(OpenAppRequest instance) =>
    <String, dynamic>{
      'appId': instance.appId,
    };

OpenQuickSettingsRequest _$OpenQuickSettingsRequestFromJson(
        Map<String, dynamic> json) =>
    OpenQuickSettingsRequest();

Map<String, dynamic> _$OpenQuickSettingsRequestToJson(
        OpenQuickSettingsRequest instance) =>
    <String, dynamic>{};

OpenUrlRequest _$OpenUrlRequestFromJson(Map<String, dynamic> json) =>
    OpenUrlRequest(
      url: json['url'] as String,
    );

Map<String, dynamic> _$OpenUrlRequestToJson(OpenUrlRequest instance) =>
    <String, dynamic>{
      'url': instance.url,
    };

AndroidSelector _$AndroidSelectorFromJson(Map<String, dynamic> json) =>
    AndroidSelector(
      className: json['className'] as String?,
      isCheckable: json['isCheckable'] as bool?,
      isChecked: json['isChecked'] as bool?,
      isClickable: json['isClickable'] as bool?,
      isEnabled: json['isEnabled'] as bool?,
      isFocusable: json['isFocusable'] as bool?,
      isFocused: json['isFocused'] as bool?,
      isLongClickable: json['isLongClickable'] as bool?,
      isScrollable: json['isScrollable'] as bool?,
      isSelected: json['isSelected'] as bool?,
      applicationPackage: json['applicationPackage'] as String?,
      contentDescription: json['contentDescription'] as String?,
      contentDescriptionStartsWith:
          json['contentDescriptionStartsWith'] as String?,
      contentDescriptionContains: json['contentDescriptionContains'] as String?,
      text: json['text'] as String?,
      textStartsWith: json['textStartsWith'] as String?,
      textContains: json['textContains'] as String?,
      resourceName: json['resourceName'] as String?,
      instance: (json['instance'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AndroidSelectorToJson(AndroidSelector instance) =>
    <String, dynamic>{
      'className': instance.className,
      'isCheckable': instance.isCheckable,
      'isChecked': instance.isChecked,
      'isClickable': instance.isClickable,
      'isEnabled': instance.isEnabled,
      'isFocusable': instance.isFocusable,
      'isFocused': instance.isFocused,
      'isLongClickable': instance.isLongClickable,
      'isScrollable': instance.isScrollable,
      'isSelected': instance.isSelected,
      'applicationPackage': instance.applicationPackage,
      'contentDescription': instance.contentDescription,
      'contentDescriptionStartsWith': instance.contentDescriptionStartsWith,
      'contentDescriptionContains': instance.contentDescriptionContains,
      'text': instance.text,
      'textStartsWith': instance.textStartsWith,
      'textContains': instance.textContains,
      'resourceName': instance.resourceName,
      'instance': instance.instance,
    };

IOSSelector _$IOSSelectorFromJson(Map<String, dynamic> json) => IOSSelector(
      value: json['value'] as String?,
      instance: (json['instance'] as num?)?.toInt(),
      elementType:
          $enumDecodeNullable(_$IOSElementTypeEnumMap, json['elementType']),
      identifier: json['identifier'] as String?,
      label: json['label'] as String?,
      labelStartsWith: json['labelStartsWith'] as String?,
      labelContains: json['labelContains'] as String?,
      title: json['title'] as String?,
      titleStartsWith: json['titleStartsWith'] as String?,
      titleContains: json['titleContains'] as String?,
      hasFocus: json['hasFocus'] as bool?,
      isEnabled: json['isEnabled'] as bool?,
      isSelected: json['isSelected'] as bool?,
      placeholderValue: json['placeholderValue'] as String?,
      placeholderValueStartsWith: json['placeholderValueStartsWith'] as String?,
      placeholderValueContains: json['placeholderValueContains'] as String?,
    );

Map<String, dynamic> _$IOSSelectorToJson(IOSSelector instance) =>
    <String, dynamic>{
      'value': instance.value,
      'instance': instance.instance,
      'elementType': _$IOSElementTypeEnumMap[instance.elementType],
      'identifier': instance.identifier,
      'label': instance.label,
      'labelStartsWith': instance.labelStartsWith,
      'labelContains': instance.labelContains,
      'title': instance.title,
      'titleStartsWith': instance.titleStartsWith,
      'titleContains': instance.titleContains,
      'hasFocus': instance.hasFocus,
      'isEnabled': instance.isEnabled,
      'isSelected': instance.isSelected,
      'placeholderValue': instance.placeholderValue,
      'placeholderValueStartsWith': instance.placeholderValueStartsWith,
      'placeholderValueContains': instance.placeholderValueContains,
    };

const _$IOSElementTypeEnumMap = {
  IOSElementType.any: 'any',
  IOSElementType.other: 'other',
  IOSElementType.application: 'application',
  IOSElementType.group: 'group',
  IOSElementType.window: 'window',
  IOSElementType.sheet: 'sheet',
  IOSElementType.drawer: 'drawer',
  IOSElementType.alert: 'alert',
  IOSElementType.dialog: 'dialog',
  IOSElementType.button: 'button',
  IOSElementType.radioButton: 'radioButton',
  IOSElementType.radioGroup: 'radioGroup',
  IOSElementType.checkBox: 'checkBox',
  IOSElementType.disclosureTriangle: 'disclosureTriangle',
  IOSElementType.popUpButton: 'popUpButton',
  IOSElementType.comboBox: 'comboBox',
  IOSElementType.menuButton: 'menuButton',
  IOSElementType.toolbarButton: 'toolbarButton',
  IOSElementType.popover: 'popover',
  IOSElementType.keyboard: 'keyboard',
  IOSElementType.key: 'key',
  IOSElementType.navigationBar: 'navigationBar',
  IOSElementType.tabBar: 'tabBar',
  IOSElementType.tabGroup: 'tabGroup',
  IOSElementType.toolbar: 'toolbar',
  IOSElementType.statusBar: 'statusBar',
  IOSElementType.table: 'table',
  IOSElementType.tableRow: 'tableRow',
  IOSElementType.tableColumn: 'tableColumn',
  IOSElementType.outline: 'outline',
  IOSElementType.outlineRow: 'outlineRow',
  IOSElementType.browser: 'browser',
  IOSElementType.collectionView: 'collectionView',
  IOSElementType.slider: 'slider',
  IOSElementType.pageIndicator: 'pageIndicator',
  IOSElementType.progressIndicator: 'progressIndicator',
  IOSElementType.activityIndicator: 'activityIndicator',
  IOSElementType.segmentedControl: 'segmentedControl',
  IOSElementType.picker: 'picker',
  IOSElementType.pickerWheel: 'pickerWheel',
  IOSElementType.switch_: 'switch_',
  IOSElementType.toggle: 'toggle',
  IOSElementType.link: 'link',
  IOSElementType.image: 'image',
  IOSElementType.icon: 'icon',
  IOSElementType.searchField: 'searchField',
  IOSElementType.scrollView: 'scrollView',
  IOSElementType.scrollBar: 'scrollBar',
  IOSElementType.staticText: 'staticText',
  IOSElementType.textField: 'textField',
  IOSElementType.secureTextField: 'secureTextField',
  IOSElementType.datePicker: 'datePicker',
  IOSElementType.textView: 'textView',
  IOSElementType.menu: 'menu',
  IOSElementType.menuItem: 'menuItem',
  IOSElementType.menuBar: 'menuBar',
  IOSElementType.menuBarItem: 'menuBarItem',
  IOSElementType.map: 'map',
  IOSElementType.webView: 'webView',
  IOSElementType.incrementArrow: 'incrementArrow',
  IOSElementType.decrementArrow: 'decrementArrow',
  IOSElementType.timeline: 'timeline',
  IOSElementType.ratingIndicator: 'ratingIndicator',
  IOSElementType.valueIndicator: 'valueIndicator',
  IOSElementType.splitGroup: 'splitGroup',
  IOSElementType.splitter: 'splitter',
  IOSElementType.relevanceIndicator: 'relevanceIndicator',
  IOSElementType.colorWell: 'colorWell',
  IOSElementType.helpTag: 'helpTag',
  IOSElementType.matte: 'matte',
  IOSElementType.dockItem: 'dockItem',
  IOSElementType.ruler: 'ruler',
  IOSElementType.rulerMarker: 'rulerMarker',
  IOSElementType.grid: 'grid',
  IOSElementType.levelIndicator: 'levelIndicator',
  IOSElementType.cell: 'cell',
  IOSElementType.layoutArea: 'layoutArea',
  IOSElementType.layoutItem: 'layoutItem',
  IOSElementType.handle: 'handle',
  IOSElementType.stepper: 'stepper',
  IOSElementType.tab: 'tab',
  IOSElementType.touchBar: 'touchBar',
  IOSElementType.statusItem: 'statusItem',
};

Selector _$SelectorFromJson(Map<String, dynamic> json) => Selector(
      text: json['text'] as String?,
      textStartsWith: json['textStartsWith'] as String?,
      textContains: json['textContains'] as String?,
      className: json['className'] as String?,
      contentDescription: json['contentDescription'] as String?,
      contentDescriptionStartsWith:
          json['contentDescriptionStartsWith'] as String?,
      contentDescriptionContains: json['contentDescriptionContains'] as String?,
      resourceId: json['resourceId'] as String?,
      instance: (json['instance'] as num?)?.toInt(),
      enabled: json['enabled'] as bool?,
      focused: json['focused'] as bool?,
      pkg: json['pkg'] as String?,
    );

Map<String, dynamic> _$SelectorToJson(Selector instance) => <String, dynamic>{
      'text': instance.text,
      'textStartsWith': instance.textStartsWith,
      'textContains': instance.textContains,
      'className': instance.className,
      'contentDescription': instance.contentDescription,
      'contentDescriptionStartsWith': instance.contentDescriptionStartsWith,
      'contentDescriptionContains': instance.contentDescriptionContains,
      'resourceId': instance.resourceId,
      'instance': instance.instance,
      'enabled': instance.enabled,
      'focused': instance.focused,
      'pkg': instance.pkg,
    };

GetNativeViewsRequest _$GetNativeViewsRequestFromJson(
        Map<String, dynamic> json) =>
    GetNativeViewsRequest(
      selector: json['selector'] == null
          ? null
          : Selector.fromJson(json['selector'] as Map<String, dynamic>),
      androidSelector: json['androidSelector'] == null
          ? null
          : AndroidSelector.fromJson(
              json['androidSelector'] as Map<String, dynamic>),
      iosSelector: json['iosSelector'] == null
          ? null
          : IOSSelector.fromJson(json['iosSelector'] as Map<String, dynamic>),
      appId: json['appId'] as String,
    );

Map<String, dynamic> _$GetNativeViewsRequestToJson(
        GetNativeViewsRequest instance) =>
    <String, dynamic>{
      'selector': instance.selector,
      'androidSelector': instance.androidSelector,
      'iosSelector': instance.iosSelector,
      'appId': instance.appId,
    };

GetNativeUITreeRequest _$GetNativeUITreeRequestFromJson(
        Map<String, dynamic> json) =>
    GetNativeUITreeRequest(
      iosInstalledApps: (json['iosInstalledApps'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      useNativeViewHierarchy: json['useNativeViewHierarchy'] as bool,
    );

Map<String, dynamic> _$GetNativeUITreeRequestToJson(
        GetNativeUITreeRequest instance) =>
    <String, dynamic>{
      'iosInstalledApps': instance.iosInstalledApps,
      'useNativeViewHierarchy': instance.useNativeViewHierarchy,
    };

GetNativeUITreeRespone _$GetNativeUITreeResponeFromJson(
        Map<String, dynamic> json) =>
    GetNativeUITreeRespone(
      iOSroots: (json['iOSroots'] as List<dynamic>)
          .map((e) => IOSNativeView.fromJson(e as Map<String, dynamic>))
          .toList(),
      androidRoots: (json['androidRoots'] as List<dynamic>)
          .map((e) => AndroidNativeView.fromJson(e as Map<String, dynamic>))
          .toList(),
      roots: (json['roots'] as List<dynamic>)
          .map((e) => NativeView.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetNativeUITreeResponeToJson(
        GetNativeUITreeRespone instance) =>
    <String, dynamic>{
      'iOSroots': instance.iOSroots,
      'androidRoots': instance.androidRoots,
      'roots': instance.roots,
    };

AndroidNativeView _$AndroidNativeViewFromJson(Map<String, dynamic> json) =>
    AndroidNativeView(
      resourceName: json['resourceName'] as String?,
      text: json['text'] as String?,
      className: json['className'] as String?,
      contentDescription: json['contentDescription'] as String?,
      applicationPackage: json['applicationPackage'] as String?,
      childCount: (json['childCount'] as num).toInt(),
      isCheckable: json['isCheckable'] as bool,
      isChecked: json['isChecked'] as bool,
      isClickable: json['isClickable'] as bool,
      isEnabled: json['isEnabled'] as bool,
      isFocusable: json['isFocusable'] as bool,
      isFocused: json['isFocused'] as bool,
      isLongClickable: json['isLongClickable'] as bool,
      isScrollable: json['isScrollable'] as bool,
      isSelected: json['isSelected'] as bool,
      visibleBounds:
          Rectangle.fromJson(json['visibleBounds'] as Map<String, dynamic>),
      visibleCenter:
          Point2D.fromJson(json['visibleCenter'] as Map<String, dynamic>),
      children: (json['children'] as List<dynamic>)
          .map((e) => AndroidNativeView.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AndroidNativeViewToJson(AndroidNativeView instance) =>
    <String, dynamic>{
      'resourceName': instance.resourceName,
      'text': instance.text,
      'className': instance.className,
      'contentDescription': instance.contentDescription,
      'applicationPackage': instance.applicationPackage,
      'childCount': instance.childCount,
      'isCheckable': instance.isCheckable,
      'isChecked': instance.isChecked,
      'isClickable': instance.isClickable,
      'isEnabled': instance.isEnabled,
      'isFocusable': instance.isFocusable,
      'isFocused': instance.isFocused,
      'isLongClickable': instance.isLongClickable,
      'isScrollable': instance.isScrollable,
      'isSelected': instance.isSelected,
      'visibleBounds': instance.visibleBounds,
      'visibleCenter': instance.visibleCenter,
      'children': instance.children,
    };

IOSNativeView _$IOSNativeViewFromJson(Map<String, dynamic> json) =>
    IOSNativeView(
      children: (json['children'] as List<dynamic>)
          .map((e) => IOSNativeView.fromJson(e as Map<String, dynamic>))
          .toList(),
      elementType: $enumDecode(_$IOSElementTypeEnumMap, json['elementType']),
      identifier: json['identifier'] as String,
      label: json['label'] as String,
      title: json['title'] as String,
      hasFocus: json['hasFocus'] as bool,
      isEnabled: json['isEnabled'] as bool,
      isSelected: json['isSelected'] as bool,
      frame: Rectangle.fromJson(json['frame'] as Map<String, dynamic>),
      placeholderValue: json['placeholderValue'] as String?,
      value: json['value'] as String?,
    );

Map<String, dynamic> _$IOSNativeViewToJson(IOSNativeView instance) =>
    <String, dynamic>{
      'children': instance.children,
      'elementType': _$IOSElementTypeEnumMap[instance.elementType]!,
      'identifier': instance.identifier,
      'label': instance.label,
      'title': instance.title,
      'hasFocus': instance.hasFocus,
      'isEnabled': instance.isEnabled,
      'isSelected': instance.isSelected,
      'frame': instance.frame,
      'placeholderValue': instance.placeholderValue,
      'value': instance.value,
    };

Rectangle _$RectangleFromJson(Map<String, dynamic> json) => Rectangle(
      minX: (json['minX'] as num).toDouble(),
      minY: (json['minY'] as num).toDouble(),
      maxX: (json['maxX'] as num).toDouble(),
      maxY: (json['maxY'] as num).toDouble(),
    );

Map<String, dynamic> _$RectangleToJson(Rectangle instance) => <String, dynamic>{
      'minX': instance.minX,
      'minY': instance.minY,
      'maxX': instance.maxX,
      'maxY': instance.maxY,
    };

Point2D _$Point2DFromJson(Map<String, dynamic> json) => Point2D(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );

Map<String, dynamic> _$Point2DToJson(Point2D instance) => <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
    };

NativeView _$NativeViewFromJson(Map<String, dynamic> json) => NativeView(
      className: json['className'] as String?,
      text: json['text'] as String?,
      contentDescription: json['contentDescription'] as String?,
      focused: json['focused'] as bool,
      enabled: json['enabled'] as bool,
      childCount: (json['childCount'] as num?)?.toInt(),
      resourceName: json['resourceName'] as String?,
      applicationPackage: json['applicationPackage'] as String?,
      children: (json['children'] as List<dynamic>)
          .map((e) => NativeView.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NativeViewToJson(NativeView instance) =>
    <String, dynamic>{
      'className': instance.className,
      'text': instance.text,
      'contentDescription': instance.contentDescription,
      'focused': instance.focused,
      'enabled': instance.enabled,
      'childCount': instance.childCount,
      'resourceName': instance.resourceName,
      'applicationPackage': instance.applicationPackage,
      'children': instance.children,
    };

GetNativeViewsResponse _$GetNativeViewsResponseFromJson(
        Map<String, dynamic> json) =>
    GetNativeViewsResponse(
      nativeViews: (json['nativeViews'] as List<dynamic>)
          .map((e) => NativeView.fromJson(e as Map<String, dynamic>))
          .toList(),
      iosNativeViews: (json['iosNativeViews'] as List<dynamic>)
          .map((e) => IOSNativeView.fromJson(e as Map<String, dynamic>))
          .toList(),
      androidNativeViews: (json['androidNativeViews'] as List<dynamic>)
          .map((e) => AndroidNativeView.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetNativeViewsResponseToJson(
        GetNativeViewsResponse instance) =>
    <String, dynamic>{
      'nativeViews': instance.nativeViews,
      'iosNativeViews': instance.iosNativeViews,
      'androidNativeViews': instance.androidNativeViews,
    };

TapRequest _$TapRequestFromJson(Map<String, dynamic> json) => TapRequest(
      selector: json['selector'] == null
          ? null
          : Selector.fromJson(json['selector'] as Map<String, dynamic>),
      androidSelector: json['androidSelector'] == null
          ? null
          : AndroidSelector.fromJson(
              json['androidSelector'] as Map<String, dynamic>),
      iosSelector: json['iosSelector'] == null
          ? null
          : IOSSelector.fromJson(json['iosSelector'] as Map<String, dynamic>),
      appId: json['appId'] as String,
      timeoutMillis: (json['timeoutMillis'] as num?)?.toInt(),
      delayBetweenTapsMillis: (json['delayBetweenTapsMillis'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TapRequestToJson(TapRequest instance) =>
    <String, dynamic>{
      'selector': instance.selector,
      'androidSelector': instance.androidSelector,
      'iosSelector': instance.iosSelector,
      'appId': instance.appId,
      'timeoutMillis': instance.timeoutMillis,
      'delayBetweenTapsMillis': instance.delayBetweenTapsMillis,
    };

TapAtRequest _$TapAtRequestFromJson(Map<String, dynamic> json) => TapAtRequest(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      appId: json['appId'] as String,
    );

Map<String, dynamic> _$TapAtRequestToJson(TapAtRequest instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
      'appId': instance.appId,
    };

EnterTextRequest _$EnterTextRequestFromJson(Map<String, dynamic> json) =>
    EnterTextRequest(
      data: json['data'] as String,
      appId: json['appId'] as String,
      index: (json['index'] as num?)?.toInt(),
      selector: json['selector'] == null
          ? null
          : Selector.fromJson(json['selector'] as Map<String, dynamic>),
      androidSelector: json['androidSelector'] == null
          ? null
          : AndroidSelector.fromJson(
              json['androidSelector'] as Map<String, dynamic>),
      iosSelector: json['iosSelector'] == null
          ? null
          : IOSSelector.fromJson(json['iosSelector'] as Map<String, dynamic>),
      keyboardBehavior:
          $enumDecode(_$KeyboardBehaviorEnumMap, json['keyboardBehavior']),
      timeoutMillis: (json['timeoutMillis'] as num?)?.toInt(),
    );

Map<String, dynamic> _$EnterTextRequestToJson(EnterTextRequest instance) =>
    <String, dynamic>{
      'data': instance.data,
      'appId': instance.appId,
      'index': instance.index,
      'selector': instance.selector,
      'androidSelector': instance.androidSelector,
      'iosSelector': instance.iosSelector,
      'keyboardBehavior': _$KeyboardBehaviorEnumMap[instance.keyboardBehavior]!,
      'timeoutMillis': instance.timeoutMillis,
    };

const _$KeyboardBehaviorEnumMap = {
  KeyboardBehavior.showAndDismiss: 'showAndDismiss',
  KeyboardBehavior.alternative: 'alternative',
};

SwipeRequest _$SwipeRequestFromJson(Map<String, dynamic> json) => SwipeRequest(
      appId: json['appId'] as String,
      startX: (json['startX'] as num).toDouble(),
      startY: (json['startY'] as num).toDouble(),
      endX: (json['endX'] as num).toDouble(),
      endY: (json['endY'] as num).toDouble(),
      steps: (json['steps'] as num).toInt(),
    );

Map<String, dynamic> _$SwipeRequestToJson(SwipeRequest instance) =>
    <String, dynamic>{
      'appId': instance.appId,
      'startX': instance.startX,
      'startY': instance.startY,
      'endX': instance.endX,
      'endY': instance.endY,
      'steps': instance.steps,
    };

WaitUntilVisibleRequest _$WaitUntilVisibleRequestFromJson(
        Map<String, dynamic> json) =>
    WaitUntilVisibleRequest(
      selector: json['selector'] == null
          ? null
          : Selector.fromJson(json['selector'] as Map<String, dynamic>),
      androidSelector: json['androidSelector'] == null
          ? null
          : AndroidSelector.fromJson(
              json['androidSelector'] as Map<String, dynamic>),
      iosSelector: json['iosSelector'] == null
          ? null
          : IOSSelector.fromJson(json['iosSelector'] as Map<String, dynamic>),
      appId: json['appId'] as String,
      timeoutMillis: (json['timeoutMillis'] as num?)?.toInt(),
    );

Map<String, dynamic> _$WaitUntilVisibleRequestToJson(
        WaitUntilVisibleRequest instance) =>
    <String, dynamic>{
      'selector': instance.selector,
      'androidSelector': instance.androidSelector,
      'iosSelector': instance.iosSelector,
      'appId': instance.appId,
      'timeoutMillis': instance.timeoutMillis,
    };

DarkModeRequest _$DarkModeRequestFromJson(Map<String, dynamic> json) =>
    DarkModeRequest(
      appId: json['appId'] as String,
    );

Map<String, dynamic> _$DarkModeRequestToJson(DarkModeRequest instance) =>
    <String, dynamic>{
      'appId': instance.appId,
    };

Notification _$NotificationFromJson(Map<String, dynamic> json) => Notification(
      appName: json['appName'] as String?,
      title: json['title'] as String,
      content: json['content'] as String,
      raw: json['raw'] as String?,
    );

Map<String, dynamic> _$NotificationToJson(Notification instance) =>
    <String, dynamic>{
      'appName': instance.appName,
      'title': instance.title,
      'content': instance.content,
      'raw': instance.raw,
    };

GetNotificationsResponse _$GetNotificationsResponseFromJson(
        Map<String, dynamic> json) =>
    GetNotificationsResponse(
      notifications: (json['notifications'] as List<dynamic>)
          .map((e) => Notification.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetNotificationsResponseToJson(
        GetNotificationsResponse instance) =>
    <String, dynamic>{
      'notifications': instance.notifications,
    };

GetNotificationsRequest _$GetNotificationsRequestFromJson(
        Map<String, dynamic> json) =>
    GetNotificationsRequest();

Map<String, dynamic> _$GetNotificationsRequestToJson(
        GetNotificationsRequest instance) =>
    <String, dynamic>{};

TapOnNotificationRequest _$TapOnNotificationRequestFromJson(
        Map<String, dynamic> json) =>
    TapOnNotificationRequest(
      index: (json['index'] as num?)?.toInt(),
      selector: json['selector'] == null
          ? null
          : Selector.fromJson(json['selector'] as Map<String, dynamic>),
      androidSelector: json['androidSelector'] == null
          ? null
          : AndroidSelector.fromJson(
              json['androidSelector'] as Map<String, dynamic>),
      iosSelector: json['iosSelector'] == null
          ? null
          : IOSSelector.fromJson(json['iosSelector'] as Map<String, dynamic>),
      timeoutMillis: (json['timeoutMillis'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TapOnNotificationRequestToJson(
        TapOnNotificationRequest instance) =>
    <String, dynamic>{
      'index': instance.index,
      'selector': instance.selector,
      'androidSelector': instance.androidSelector,
      'iosSelector': instance.iosSelector,
      'timeoutMillis': instance.timeoutMillis,
    };

PermissionDialogVisibleResponse _$PermissionDialogVisibleResponseFromJson(
        Map<String, dynamic> json) =>
    PermissionDialogVisibleResponse(
      visible: json['visible'] as bool,
    );

Map<String, dynamic> _$PermissionDialogVisibleResponseToJson(
        PermissionDialogVisibleResponse instance) =>
    <String, dynamic>{
      'visible': instance.visible,
    };

PermissionDialogVisibleRequest _$PermissionDialogVisibleRequestFromJson(
        Map<String, dynamic> json) =>
    PermissionDialogVisibleRequest(
      timeoutMillis: (json['timeoutMillis'] as num).toInt(),
    );

Map<String, dynamic> _$PermissionDialogVisibleRequestToJson(
        PermissionDialogVisibleRequest instance) =>
    <String, dynamic>{
      'timeoutMillis': instance.timeoutMillis,
    };

HandlePermissionRequest _$HandlePermissionRequestFromJson(
        Map<String, dynamic> json) =>
    HandlePermissionRequest(
      code: $enumDecode(_$HandlePermissionRequestCodeEnumMap, json['code']),
    );

Map<String, dynamic> _$HandlePermissionRequestToJson(
        HandlePermissionRequest instance) =>
    <String, dynamic>{
      'code': _$HandlePermissionRequestCodeEnumMap[instance.code]!,
    };

const _$HandlePermissionRequestCodeEnumMap = {
  HandlePermissionRequestCode.whileUsing: 'whileUsing',
  HandlePermissionRequestCode.onlyThisTime: 'onlyThisTime',
  HandlePermissionRequestCode.denied: 'denied',
};

SetLocationAccuracyRequest _$SetLocationAccuracyRequestFromJson(
        Map<String, dynamic> json) =>
    SetLocationAccuracyRequest(
      locationAccuracy: $enumDecode(
          _$SetLocationAccuracyRequestLocationAccuracyEnumMap,
          json['locationAccuracy']),
    );

Map<String, dynamic> _$SetLocationAccuracyRequestToJson(
        SetLocationAccuracyRequest instance) =>
    <String, dynamic>{
      'locationAccuracy': _$SetLocationAccuracyRequestLocationAccuracyEnumMap[
          instance.locationAccuracy]!,
    };

const _$SetLocationAccuracyRequestLocationAccuracyEnumMap = {
  SetLocationAccuracyRequestLocationAccuracy.coarse: 'coarse',
  SetLocationAccuracyRequestLocationAccuracy.fine: 'fine',
};
