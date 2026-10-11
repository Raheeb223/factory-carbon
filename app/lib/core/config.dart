/// Build-time configuration from `--dart-define` values. No secrets live here:
/// APP_TOKEN is a weak shared token (see README), the Gemini key stays on the backend.
class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.appToken,
    required this.mapTileUrl,
    required this.mapTileAttribution,
    required this.satelliteTileUrl,
    required this.satelliteTileAttribution,
    required this.userAgentPackageName,
  });

  factory AppConfig.fromEnvironment() => const AppConfig(
        apiBaseUrl: String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8000'),
        appToken: String.fromEnvironment('APP_TOKEN'),
        // OSM standard tiles: light use only, attribution required, no bulk/offline download.
        mapTileUrl: String.fromEnvironment('MAP_TILE_URL', defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
        mapTileAttribution: String.fromEnvironment('MAP_TILE_ATTRIBUTION', defaultValue: '© OpenStreetMap contributors'),
        // Satellite imagery is off unless a provider whose terms permit this use is configured.
        satelliteTileUrl: String.fromEnvironment('SATELLITE_TILE_URL'),
        satelliteTileAttribution: String.fromEnvironment('SATELLITE_TILE_ATTRIBUTION'),
        userAgentPackageName: 'org.factorycarbon.factory_carbon',
      );

  final String apiBaseUrl;
  final String appToken;
  final String mapTileUrl;
  final String mapTileAttribution;
  final String satelliteTileUrl;
  final String satelliteTileAttribution;
  final String userAgentPackageName;

  bool get hasSatellite => satelliteTileUrl.isNotEmpty;

  AppConfig withServer({String? apiBaseUrl, String? appToken}) => AppConfig(
        apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
        appToken: appToken ?? this.appToken,
        mapTileUrl: mapTileUrl,
        mapTileAttribution: mapTileAttribution,
        satelliteTileUrl: satelliteTileUrl,
        satelliteTileAttribution: satelliteTileAttribution,
        userAgentPackageName: userAgentPackageName,
      );
}

/// Normalises a user-typed server address: trims, adds http:// if missing,
/// drops trailing slashes. Returns null if it is not a usable http(s) URL.
String? normalizeServerUrl(String input) {
  var s = input.trim();
  if (s.isEmpty) return null;
  if (!s.contains('://')) s = 'http://$s';
  while (s.endsWith('/')) {
    s = s.substring(0, s.length - 1);
  }
  final uri = Uri.tryParse(s);
  if (uri == null || !(uri.scheme == 'http' || uri.scheme == 'https') || uri.host.isEmpty) return null;
  return s;
}
