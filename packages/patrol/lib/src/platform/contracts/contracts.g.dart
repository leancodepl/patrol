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
      'entries': instance.entries.map((e) => e.toJson()).toList(),
      'skip': instance.skip,
      'tags': instance.tags,
    };

const _$GroupEntryTypeEnumMap = {
  GroupEntryType.group: 'group',
  GroupEntryType.test: 'test',
};

ListDartTestsResponse _$ListDartTestsResponseFromJson(
  Map<String, dynamic> json,
) => ListDartTestsResponse(
  group: DartGroupEntry.fromJson(json['group'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ListDartTestsResponseToJson(
  ListDartTestsResponse instance,
) => <String, dynamic>{'group': instance.group.toJson()};

RunDartTestRequest _$RunDartTestRequestFromJson(Map<String, dynamic> json) =>
    RunDartTestRequest(name: json['name'] as String);

Map<String, dynamic> _$RunDartTestRequestToJson(RunDartTestRequest instance) =>
    <String, dynamic>{'name': instance.name};

RunDartTestResponse _$RunDartTestResponseFromJson(Map<String, dynamic> json) =>
    RunDartTestResponse(
      result: $enumDecode(_$RunDartTestResponseResultEnumMap, json['result']),
      details: json['details'] as String?,
    );

Map<String, dynamic> _$RunDartTestResponseToJson(
  RunDartTestResponse instance,
) => <String, dynamic>{
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
    <String, dynamic>{'findTimeoutMillis': instance.findTimeoutMillis};

OpenAppRequest _$OpenAppRequestFromJson(Map<String, dynamic> json) =>
    OpenAppRequest(appId: json['appId'] as String);

Map<String, dynamic> _$OpenAppRequestToJson(OpenAppRequest instance) =>
    <String, dynamic>{'appId': instance.appId};

OpenPlatformAppRequest _$OpenPlatformAppRequestFromJson(
  Map<String, dynamic> json,
) => OpenPlatformAppRequest(
  androidAppId: json['androidAppId'] as String?,
  iosAppId: json['iosAppId'] as String?,
);

Map<String, dynamic> _$OpenPlatformAppRequestToJson(
  OpenPlatformAppRequest instance,
) => <String, dynamic>{
  'androidAppId': instance.androidAppId,
  'iosAppId': instance.iosAppId,
};

OpenQuickSettingsRequest _$OpenQuickSettingsRequestFromJson(
  Map<String, dynamic> json,
) => OpenQuickSettingsRequest();

Map<String, dynamic> _$OpenQuickSettingsRequestToJson(
  OpenQuickSettingsRequest instance,
) => <String, dynamic>{};

OpenUrlRequest _$OpenUrlRequestFromJson(Map<String, dynamic> json) =>
    OpenUrlRequest(url: json['url'] as String);

Map<String, dynamic> _$OpenUrlRequestToJson(OpenUrlRequest instance) =>
    <String, dynamic>{'url': instance.url};

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
  elementType: $enumDecodeNullable(
    _$IOSElementTypeEnumMap,
    json['elementType'],
  ),
  identifier: json['identifier'] as String?,
  text: json['text'] as String?,
  textStartsWith: json['textStartsWith'] as String?,
  textContains: json['textContains'] as String?,
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
      'text': instance.text,
      'textStartsWith': instance.textStartsWith,
      'textContains': instance.textContains,
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

AndroidGetNativeViewsRequest _$AndroidGetNativeViewsRequestFromJson(
  Map<String, dynamic> json,
) => AndroidGetNativeViewsRequest(
  selector: json['selector'] == null
      ? null
      : AndroidSelector.fromJson(json['selector'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AndroidGetNativeViewsRequestToJson(
  AndroidGetNativeViewsRequest instance,
) => <String, dynamic>{'selector': instance.selector?.toJson()};

IOSGetNativeViewsRequest _$IOSGetNativeViewsRequestFromJson(
  Map<String, dynamic> json,
) => IOSGetNativeViewsRequest(
  selector: json['selector'] == null
      ? null
      : IOSSelector.fromJson(json['selector'] as Map<String, dynamic>),
  iosInstalledApps: (json['iosInstalledApps'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  appId: json['appId'] as String,
);

Map<String, dynamic> _$IOSGetNativeViewsRequestToJson(
  IOSGetNativeViewsRequest instance,
) => <String, dynamic>{
  'selector': instance.selector?.toJson(),
  'iosInstalledApps': instance.iosInstalledApps,
  'appId': instance.appId,
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
      visibleBounds: Rectangle.fromJson(
        json['visibleBounds'] as Map<String, dynamic>,
      ),
      visibleCenter: Point2D.fromJson(
        json['visibleCenter'] as Map<String, dynamic>,
      ),
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
      'visibleBounds': instance.visibleBounds.toJson(),
      'visibleCenter': instance.visibleCenter.toJson(),
      'children': instance.children.map((e) => e.toJson()).toList(),
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
      accessibilityLabel: json['accessibilityLabel'] as String?,
      placeholderValue: json['placeholderValue'] as String?,
      value: json['value'] as String?,
      bundleId: json['bundleId'] as String?,
    );

Map<String, dynamic> _$IOSNativeViewToJson(IOSNativeView instance) =>
    <String, dynamic>{
      'children': instance.children.map((e) => e.toJson()).toList(),
      'elementType': _$IOSElementTypeEnumMap[instance.elementType]!,
      'identifier': instance.identifier,
      'label': instance.label,
      'title': instance.title,
      'hasFocus': instance.hasFocus,
      'isEnabled': instance.isEnabled,
      'isSelected': instance.isSelected,
      'frame': instance.frame.toJson(),
      'accessibilityLabel': instance.accessibilityLabel,
      'placeholderValue': instance.placeholderValue,
      'value': instance.value,
      'bundleId': instance.bundleId,
    };

AndroidGetNativeViewsResponse _$AndroidGetNativeViewsResponseFromJson(
  Map<String, dynamic> json,
) => AndroidGetNativeViewsResponse(
  roots: (json['roots'] as List<dynamic>)
      .map((e) => AndroidNativeView.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$AndroidGetNativeViewsResponseToJson(
  AndroidGetNativeViewsResponse instance,
) => <String, dynamic>{'roots': instance.roots.map((e) => e.toJson()).toList()};

IOSGetNativeViewsResponse _$IOSGetNativeViewsResponseFromJson(
  Map<String, dynamic> json,
) => IOSGetNativeViewsResponse(
  roots: (json['roots'] as List<dynamic>)
      .map((e) => IOSNativeView.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$IOSGetNativeViewsResponseToJson(
  IOSGetNativeViewsResponse instance,
) => <String, dynamic>{'roots': instance.roots.map((e) => e.toJson()).toList()};

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

Point2D _$Point2DFromJson(Map<String, dynamic> json) =>
    Point2D(x: (json['x'] as num).toDouble(), y: (json['y'] as num).toDouble());

Map<String, dynamic> _$Point2DToJson(Point2D instance) => <String, dynamic>{
  'x': instance.x,
  'y': instance.y,
};

AndroidTapRequest _$AndroidTapRequestFromJson(Map<String, dynamic> json) =>
    AndroidTapRequest(
      selector: json['selector'] == null
          ? null
          : AndroidSelector.fromJson(json['selector'] as Map<String, dynamic>),
      timeoutMillis: (json['timeoutMillis'] as num?)?.toInt(),
      delayBetweenTapsMillis: (json['delayBetweenTapsMillis'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AndroidTapRequestToJson(AndroidTapRequest instance) =>
    <String, dynamic>{
      'selector': instance.selector?.toJson(),
      'timeoutMillis': instance.timeoutMillis,
      'delayBetweenTapsMillis': instance.delayBetweenTapsMillis,
    };

IOSTapRequest _$IOSTapRequestFromJson(Map<String, dynamic> json) =>
    IOSTapRequest(
      selector: IOSSelector.fromJson(json['selector'] as Map<String, dynamic>),
      appId: json['appId'] as String,
      timeoutMillis: (json['timeoutMillis'] as num?)?.toInt(),
    );

Map<String, dynamic> _$IOSTapRequestToJson(IOSTapRequest instance) =>
    <String, dynamic>{
      'selector': instance.selector.toJson(),
      'appId': instance.appId,
      'timeoutMillis': instance.timeoutMillis,
    };

AndroidTapAtRequest _$AndroidTapAtRequestFromJson(Map<String, dynamic> json) =>
    AndroidTapAtRequest(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );

Map<String, dynamic> _$AndroidTapAtRequestToJson(
  AndroidTapAtRequest instance,
) => <String, dynamic>{'x': instance.x, 'y': instance.y};

IOSTapAtRequest _$IOSTapAtRequestFromJson(Map<String, dynamic> json) =>
    IOSTapAtRequest(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      appId: json['appId'] as String,
    );

Map<String, dynamic> _$IOSTapAtRequestToJson(IOSTapAtRequest instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
      'appId': instance.appId,
    };

AndroidEnterTextRequest _$AndroidEnterTextRequestFromJson(
  Map<String, dynamic> json,
) => AndroidEnterTextRequest(
  data: json['data'] as String,
  index: (json['index'] as num?)?.toInt(),
  selector: json['selector'] == null
      ? null
      : AndroidSelector.fromJson(json['selector'] as Map<String, dynamic>),
  keyboardBehavior: $enumDecode(
    _$KeyboardBehaviorEnumMap,
    json['keyboardBehavior'],
  ),
  timeoutMillis: (json['timeoutMillis'] as num?)?.toInt(),
  dx: (json['dx'] as num?)?.toDouble(),
  dy: (json['dy'] as num?)?.toDouble(),
);

Map<String, dynamic> _$AndroidEnterTextRequestToJson(
  AndroidEnterTextRequest instance,
) => <String, dynamic>{
  'data': instance.data,
  'index': instance.index,
  'selector': instance.selector?.toJson(),
  'keyboardBehavior': _$KeyboardBehaviorEnumMap[instance.keyboardBehavior]!,
  'timeoutMillis': instance.timeoutMillis,
  'dx': instance.dx,
  'dy': instance.dy,
};

const _$KeyboardBehaviorEnumMap = {
  KeyboardBehavior.showAndDismiss: 'showAndDismiss',
  KeyboardBehavior.alternative: 'alternative',
};

IOSEnterTextRequest _$IOSEnterTextRequestFromJson(Map<String, dynamic> json) =>
    IOSEnterTextRequest(
      data: json['data'] as String,
      appId: json['appId'] as String,
      index: (json['index'] as num?)?.toInt(),
      selector: json['selector'] == null
          ? null
          : IOSSelector.fromJson(json['selector'] as Map<String, dynamic>),
      keyboardBehavior: $enumDecode(
        _$KeyboardBehaviorEnumMap,
        json['keyboardBehavior'],
      ),
      timeoutMillis: (json['timeoutMillis'] as num?)?.toInt(),
      dx: (json['dx'] as num?)?.toDouble(),
      dy: (json['dy'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$IOSEnterTextRequestToJson(
  IOSEnterTextRequest instance,
) => <String, dynamic>{
  'data': instance.data,
  'appId': instance.appId,
  'index': instance.index,
  'selector': instance.selector?.toJson(),
  'keyboardBehavior': _$KeyboardBehaviorEnumMap[instance.keyboardBehavior]!,
  'timeoutMillis': instance.timeoutMillis,
  'dx': instance.dx,
  'dy': instance.dy,
};

AndroidSwipeRequest _$AndroidSwipeRequestFromJson(Map<String, dynamic> json) =>
    AndroidSwipeRequest(
      startX: (json['startX'] as num).toDouble(),
      startY: (json['startY'] as num).toDouble(),
      endX: (json['endX'] as num).toDouble(),
      endY: (json['endY'] as num).toDouble(),
      steps: (json['steps'] as num).toInt(),
    );

Map<String, dynamic> _$AndroidSwipeRequestToJson(
  AndroidSwipeRequest instance,
) => <String, dynamic>{
  'startX': instance.startX,
  'startY': instance.startY,
  'endX': instance.endX,
  'endY': instance.endY,
  'steps': instance.steps,
};

IOSSwipeRequest _$IOSSwipeRequestFromJson(Map<String, dynamic> json) =>
    IOSSwipeRequest(
      appId: json['appId'] as String,
      startX: (json['startX'] as num).toDouble(),
      startY: (json['startY'] as num).toDouble(),
      endX: (json['endX'] as num).toDouble(),
      endY: (json['endY'] as num).toDouble(),
    );

Map<String, dynamic> _$IOSSwipeRequestToJson(IOSSwipeRequest instance) =>
    <String, dynamic>{
      'appId': instance.appId,
      'startX': instance.startX,
      'startY': instance.startY,
      'endX': instance.endX,
      'endY': instance.endY,
    };

AndroidWaitUntilVisibleRequest _$AndroidWaitUntilVisibleRequestFromJson(
  Map<String, dynamic> json,
) => AndroidWaitUntilVisibleRequest(
  selector: AndroidSelector.fromJson(json['selector'] as Map<String, dynamic>),
  timeoutMillis: (json['timeoutMillis'] as num?)?.toInt(),
);

Map<String, dynamic> _$AndroidWaitUntilVisibleRequestToJson(
  AndroidWaitUntilVisibleRequest instance,
) => <String, dynamic>{
  'selector': instance.selector.toJson(),
  'timeoutMillis': instance.timeoutMillis,
};

IOSTwaitUntilVisibleRequest _$IOSTwaitUntilVisibleRequestFromJson(
  Map<String, dynamic> json,
) => IOSTwaitUntilVisibleRequest(
  selector: IOSSelector.fromJson(json['selector'] as Map<String, dynamic>),
  appId: json['appId'] as String,
  timeoutMillis: (json['timeoutMillis'] as num?)?.toInt(),
);

Map<String, dynamic> _$IOSTwaitUntilVisibleRequestToJson(
  IOSTwaitUntilVisibleRequest instance,
) => <String, dynamic>{
  'selector': instance.selector.toJson(),
  'appId': instance.appId,
  'timeoutMillis': instance.timeoutMillis,
};

DarkModeRequest _$DarkModeRequestFromJson(Map<String, dynamic> json) =>
    DarkModeRequest(appId: json['appId'] as String);

Map<String, dynamic> _$DarkModeRequestToJson(DarkModeRequest instance) =>
    <String, dynamic>{'appId': instance.appId};

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
  Map<String, dynamic> json,
) => GetNotificationsResponse(
  notifications: (json['notifications'] as List<dynamic>)
      .map((e) => Notification.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GetNotificationsResponseToJson(
  GetNotificationsResponse instance,
) => <String, dynamic>{
  'notifications': instance.notifications.map((e) => e.toJson()).toList(),
};

GetNotificationsRequest _$GetNotificationsRequestFromJson(
  Map<String, dynamic> json,
) => GetNotificationsRequest();

Map<String, dynamic> _$GetNotificationsRequestToJson(
  GetNotificationsRequest instance,
) => <String, dynamic>{};

AndroidTapOnNotificationRequest _$AndroidTapOnNotificationRequestFromJson(
  Map<String, dynamic> json,
) => AndroidTapOnNotificationRequest(
  index: (json['index'] as num?)?.toInt(),
  selector: json['selector'] == null
      ? null
      : AndroidSelector.fromJson(json['selector'] as Map<String, dynamic>),
  timeoutMillis: (json['timeoutMillis'] as num?)?.toInt(),
);

Map<String, dynamic> _$AndroidTapOnNotificationRequestToJson(
  AndroidTapOnNotificationRequest instance,
) => <String, dynamic>{
  'index': instance.index,
  'selector': instance.selector?.toJson(),
  'timeoutMillis': instance.timeoutMillis,
};

IOSTapOnNotificationRequest _$IOSTapOnNotificationRequestFromJson(
  Map<String, dynamic> json,
) => IOSTapOnNotificationRequest(
  index: (json['index'] as num?)?.toInt(),
  selector: json['selector'] == null
      ? null
      : IOSSelector.fromJson(json['selector'] as Map<String, dynamic>),
  timeoutMillis: (json['timeoutMillis'] as num?)?.toInt(),
);

Map<String, dynamic> _$IOSTapOnNotificationRequestToJson(
  IOSTapOnNotificationRequest instance,
) => <String, dynamic>{
  'index': instance.index,
  'selector': instance.selector?.toJson(),
  'timeoutMillis': instance.timeoutMillis,
};

PermissionDialogVisibleResponse _$PermissionDialogVisibleResponseFromJson(
  Map<String, dynamic> json,
) => PermissionDialogVisibleResponse(visible: json['visible'] as bool);

Map<String, dynamic> _$PermissionDialogVisibleResponseToJson(
  PermissionDialogVisibleResponse instance,
) => <String, dynamic>{'visible': instance.visible};

PermissionDialogVisibleRequest _$PermissionDialogVisibleRequestFromJson(
  Map<String, dynamic> json,
) => PermissionDialogVisibleRequest(
  timeoutMillis: (json['timeoutMillis'] as num).toInt(),
);

Map<String, dynamic> _$PermissionDialogVisibleRequestToJson(
  PermissionDialogVisibleRequest instance,
) => <String, dynamic>{'timeoutMillis': instance.timeoutMillis};

HandlePermissionRequest _$HandlePermissionRequestFromJson(
  Map<String, dynamic> json,
) => HandlePermissionRequest(
  code: $enumDecode(_$HandlePermissionRequestCodeEnumMap, json['code']),
);

Map<String, dynamic> _$HandlePermissionRequestToJson(
  HandlePermissionRequest instance,
) => <String, dynamic>{
  'code': _$HandlePermissionRequestCodeEnumMap[instance.code]!,
};

const _$HandlePermissionRequestCodeEnumMap = {
  HandlePermissionRequestCode.whileUsing: 'whileUsing',
  HandlePermissionRequestCode.onlyThisTime: 'onlyThisTime',
  HandlePermissionRequestCode.denied: 'denied',
};

SetLocationAccuracyRequest _$SetLocationAccuracyRequestFromJson(
  Map<String, dynamic> json,
) => SetLocationAccuracyRequest(
  locationAccuracy: $enumDecode(
    _$SetLocationAccuracyRequestLocationAccuracyEnumMap,
    json['locationAccuracy'],
  ),
);

Map<String, dynamic> _$SetLocationAccuracyRequestToJson(
  SetLocationAccuracyRequest instance,
) => <String, dynamic>{
  'locationAccuracy':
      _$SetLocationAccuracyRequestLocationAccuracyEnumMap[instance
          .locationAccuracy]!,
};

const _$SetLocationAccuracyRequestLocationAccuracyEnumMap = {
  SetLocationAccuracyRequestLocationAccuracy.coarse: 'coarse',
  SetLocationAccuracyRequestLocationAccuracy.fine: 'fine',
};

SetMockLocationRequest _$SetMockLocationRequestFromJson(
  Map<String, dynamic> json,
) => SetMockLocationRequest(
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  packageName: json['packageName'] as String,
);

Map<String, dynamic> _$SetMockLocationRequestToJson(
  SetMockLocationRequest instance,
) => <String, dynamic>{
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'packageName': instance.packageName,
};

IsVirtualDeviceResponse _$IsVirtualDeviceResponseFromJson(
  Map<String, dynamic> json,
) => IsVirtualDeviceResponse(isVirtualDevice: json['isVirtualDevice'] as bool);

Map<String, dynamic> _$IsVirtualDeviceResponseToJson(
  IsVirtualDeviceResponse instance,
) => <String, dynamic>{'isVirtualDevice': instance.isVirtualDevice};

GetOsVersionResponse _$GetOsVersionResponseFromJson(
  Map<String, dynamic> json,
) => GetOsVersionResponse(osVersion: (json['osVersion'] as num).toInt());

Map<String, dynamic> _$GetOsVersionResponseToJson(
  GetOsVersionResponse instance,
) => <String, dynamic>{'osVersion': instance.osVersion};

AndroidTakeCameraPhotoRequest _$AndroidTakeCameraPhotoRequestFromJson(
  Map<String, dynamic> json,
) => AndroidTakeCameraPhotoRequest(
  shutterButtonSelector: json['shutterButtonSelector'] == null
      ? null
      : AndroidSelector.fromJson(
          json['shutterButtonSelector'] as Map<String, dynamic>,
        ),
  doneButtonSelector: json['doneButtonSelector'] == null
      ? null
      : AndroidSelector.fromJson(
          json['doneButtonSelector'] as Map<String, dynamic>,
        ),
  timeoutMillis: (json['timeoutMillis'] as num?)?.toInt(),
);

Map<String, dynamic> _$AndroidTakeCameraPhotoRequestToJson(
  AndroidTakeCameraPhotoRequest instance,
) => <String, dynamic>{
  'shutterButtonSelector': instance.shutterButtonSelector?.toJson(),
  'doneButtonSelector': instance.doneButtonSelector?.toJson(),
  'timeoutMillis': instance.timeoutMillis,
};

IOSTakeCameraPhotoRequest _$IOSTakeCameraPhotoRequestFromJson(
  Map<String, dynamic> json,
) => IOSTakeCameraPhotoRequest(
  shutterButtonSelector: json['shutterButtonSelector'] == null
      ? null
      : IOSSelector.fromJson(
          json['shutterButtonSelector'] as Map<String, dynamic>,
        ),
  doneButtonSelector: json['doneButtonSelector'] == null
      ? null
      : IOSSelector.fromJson(
          json['doneButtonSelector'] as Map<String, dynamic>,
        ),
  timeoutMillis: (json['timeoutMillis'] as num?)?.toInt(),
  appId: json['appId'] as String,
);

Map<String, dynamic> _$IOSTakeCameraPhotoRequestToJson(
  IOSTakeCameraPhotoRequest instance,
) => <String, dynamic>{
  'shutterButtonSelector': instance.shutterButtonSelector?.toJson(),
  'doneButtonSelector': instance.doneButtonSelector?.toJson(),
  'timeoutMillis': instance.timeoutMillis,
  'appId': instance.appId,
};

AndroidPickImageFromGalleryRequest _$AndroidPickImageFromGalleryRequestFromJson(
  Map<String, dynamic> json,
) => AndroidPickImageFromGalleryRequest(
  imageSelector: json['imageSelector'] == null
      ? null
      : AndroidSelector.fromJson(json['imageSelector'] as Map<String, dynamic>),
  imageIndex: (json['imageIndex'] as num?)?.toInt(),
  timeoutMillis: (json['timeoutMillis'] as num?)?.toInt(),
);

Map<String, dynamic> _$AndroidPickImageFromGalleryRequestToJson(
  AndroidPickImageFromGalleryRequest instance,
) => <String, dynamic>{
  'imageSelector': instance.imageSelector?.toJson(),
  'imageIndex': instance.imageIndex,
  'timeoutMillis': instance.timeoutMillis,
};

IOSPickImageFromGalleryRequest _$IOSPickImageFromGalleryRequestFromJson(
  Map<String, dynamic> json,
) => IOSPickImageFromGalleryRequest(
  imageSelector: json['imageSelector'] == null
      ? null
      : IOSSelector.fromJson(json['imageSelector'] as Map<String, dynamic>),
  imageIndex: (json['imageIndex'] as num?)?.toInt(),
  timeoutMillis: (json['timeoutMillis'] as num?)?.toInt(),
  appId: json['appId'] as String,
);

Map<String, dynamic> _$IOSPickImageFromGalleryRequestToJson(
  IOSPickImageFromGalleryRequest instance,
) => <String, dynamic>{
  'imageSelector': instance.imageSelector?.toJson(),
  'imageIndex': instance.imageIndex,
  'timeoutMillis': instance.timeoutMillis,
  'appId': instance.appId,
};

AndroidPickMultipleImagesFromGalleryRequest
_$AndroidPickMultipleImagesFromGalleryRequestFromJson(
  Map<String, dynamic> json,
) => AndroidPickMultipleImagesFromGalleryRequest(
  imageSelector: json['imageSelector'] == null
      ? null
      : AndroidSelector.fromJson(json['imageSelector'] as Map<String, dynamic>),
  imageIndexes: (json['imageIndexes'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  timeoutMillis: (json['timeoutMillis'] as num?)?.toInt(),
);

Map<String, dynamic> _$AndroidPickMultipleImagesFromGalleryRequestToJson(
  AndroidPickMultipleImagesFromGalleryRequest instance,
) => <String, dynamic>{
  'imageSelector': instance.imageSelector?.toJson(),
  'imageIndexes': instance.imageIndexes,
  'timeoutMillis': instance.timeoutMillis,
};

IOSPickMultipleImagesFromGalleryRequest
_$IOSPickMultipleImagesFromGalleryRequestFromJson(Map<String, dynamic> json) =>
    IOSPickMultipleImagesFromGalleryRequest(
      imageSelector: json['imageSelector'] == null
          ? null
          : IOSSelector.fromJson(json['imageSelector'] as Map<String, dynamic>),
      imageIndexes: (json['imageIndexes'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      timeoutMillis: (json['timeoutMillis'] as num?)?.toInt(),
      appId: json['appId'] as String,
    );

Map<String, dynamic> _$IOSPickMultipleImagesFromGalleryRequestToJson(
  IOSPickMultipleImagesFromGalleryRequest instance,
) => <String, dynamic>{
  'imageSelector': instance.imageSelector?.toJson(),
  'imageIndexes': instance.imageIndexes,
  'timeoutMillis': instance.timeoutMillis,
  'appId': instance.appId,
};
