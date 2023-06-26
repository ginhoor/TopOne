/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsIconGen {
  const $AssetsIconGen();

  /// File path: assets/icon/ttd_icon.png
  AssetGenImage get ttdIcon => const AssetGenImage('assets/icon/ttd_icon.png');

  /// List of all assets
  List<AssetGenImage> get values => [ttdIcon];
}

class $AssetsImageGen {
  const $AssetsImageGen();

  /// File path: assets/image/app_logo.png
  AssetGenImage get appLogo => const AssetGenImage('assets/image/app_logo.png');

  /// List of all assets
  List<AssetGenImage> get values => [appLogo];
}

class $AssetsTranslationsGen {
  const $AssetsTranslationsGen();

  /// File path: assets/translations/ar.json
  String get ar => 'assets/translations/ar.json';

  /// File path: assets/translations/de.json
  String get de => 'assets/translations/de.json';

  /// File path: assets/translations/en.json
  String get en => 'assets/translations/en.json';

  /// File path: assets/translations/es.json
  String get es => 'assets/translations/es.json';

  /// File path: assets/translations/fa.json
  String get fa => 'assets/translations/fa.json';

  /// File path: assets/translations/fr.json
  String get fr => 'assets/translations/fr.json';

  /// File path: assets/translations/hi.json
  String get hi => 'assets/translations/hi.json';

  /// File path: assets/translations/id.json
  String get id => 'assets/translations/id.json';

  /// File path: assets/translations/it.json
  String get it => 'assets/translations/it.json';

  /// File path: assets/translations/ja.json
  String get ja => 'assets/translations/ja.json';

  /// File path: assets/translations/ko.json
  String get ko => 'assets/translations/ko.json';

  /// File path: assets/translations/pt-BR.json
  String get ptBR => 'assets/translations/pt-BR.json';

  /// File path: assets/translations/ru.json
  String get ru => 'assets/translations/ru.json';

  /// File path: assets/translations/th.json
  String get th => 'assets/translations/th.json';

  /// File path: assets/translations/tr.json
  String get tr => 'assets/translations/tr.json';

  /// File path: assets/translations/vi.json
  String get vi => 'assets/translations/vi.json';

  /// File path: assets/translations/zh-Hans.json
  String get zhHans => 'assets/translations/zh-Hans.json';

  /// File path: assets/translations/zh-Hant.json
  String get zhHant => 'assets/translations/zh-Hant.json';

  /// List of all assets
  List<String> get values => [
        ar,
        de,
        en,
        es,
        fa,
        fr,
        hi,
        id,
        it,
        ja,
        ko,
        ptBR,
        ru,
        th,
        tr,
        vi,
        zhHans,
        zhHant
      ];
}

class Assets {
  Assets._();

  static const $AssetsIconGen icon = $AssetsIconGen();
  static const $AssetsImageGen image = $AssetsImageGen();
  static const $AssetsTranslationsGen translations = $AssetsTranslationsGen();
}

class AssetGenImage {
  const AssetGenImage(this._assetName);

  final String _assetName;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
