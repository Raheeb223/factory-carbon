import 'package:shared_preferences/shared_preferences.dart';

/// Small per-device preferences (not user business data).
abstract interface class SettingsStore {
  bool get keepImages;
  Future<void> setKeepImages(bool v);

  bool get uploadNoticeAcknowledged;
  Future<void> setUploadNoticeAcknowledged(bool v);

  /// 'en' or 'bn'; null = follow the device.
  String? get localeCode;
  Future<void> setLocaleCode(String? v);

  /// Server address/token chosen in Settings; null = use the build-time default.
  String? get serverUrl;
  String? get serverToken;
  Future<void> setServer(String? url, String? token);

  Future<void> clear();
}

class PrefsSettingsStore implements SettingsStore {
  PrefsSettingsStore(this._prefs);
  final SharedPreferencesWithCache _prefs;

  static const _keepImages = 'keep_images';
  static const _uploadNoticeAck = 'upload_notice_ack';
  static const _locale = 'locale';
  static const _serverUrl = 'server_url';
  static const _serverToken = 'server_token';

  static Future<PrefsSettingsStore> open() async => PrefsSettingsStore(await SharedPreferencesWithCache.create(
        cacheOptions: const SharedPreferencesWithCacheOptions(
          allowList: {_keepImages, _uploadNoticeAck, _locale, _serverUrl, _serverToken},
        ),
      ));

  @override
  bool get keepImages => _prefs.getBool(_keepImages) ?? false;
  @override
  Future<void> setKeepImages(bool v) => _prefs.setBool(_keepImages, v);

  @override
  bool get uploadNoticeAcknowledged => _prefs.getBool(_uploadNoticeAck) ?? false;
  @override
  Future<void> setUploadNoticeAcknowledged(bool v) => _prefs.setBool(_uploadNoticeAck, v);

  @override
  String? get localeCode => _prefs.getString(_locale);
  @override
  Future<void> setLocaleCode(String? v) => v == null ? _prefs.remove(_locale) : _prefs.setString(_locale, v);

  @override
  String? get serverUrl => _prefs.getString(_serverUrl);
  @override
  String? get serverToken => _prefs.getString(_serverToken);
  @override
  Future<void> setServer(String? url, String? token) async {
    url == null ? await _prefs.remove(_serverUrl) : await _prefs.setString(_serverUrl, url);
    token == null ? await _prefs.remove(_serverToken) : await _prefs.setString(_serverToken, token);
  }

  @override
  Future<void> clear() => _prefs.clear();
}

/// In-memory implementation (tests, previews).
class MemorySettingsStore implements SettingsStore {
  @override
  bool keepImages = false;
  @override
  bool uploadNoticeAcknowledged = false;
  @override
  String? localeCode;
  @override
  String? serverUrl;
  @override
  String? serverToken;

  @override
  Future<void> setKeepImages(bool v) async => keepImages = v;
  @override
  Future<void> setUploadNoticeAcknowledged(bool v) async => uploadNoticeAcknowledged = v;
  @override
  Future<void> setLocaleCode(String? v) async => localeCode = v;
  @override
  Future<void> setServer(String? url, String? token) async {
    serverUrl = url;
    serverToken = token;
  }

  @override
  Future<void> clear() async {
    keepImages = false;
    uploadNoticeAcknowledged = false;
    localeCode = null;
    serverUrl = null;
    serverToken = null;
  }
}
