/// Esri World Imagery tiles, used for the satellite layer when ARCGIS_API_KEY is set
/// (a free ArcGIS Location Platform key with the basemaps privilege; free monthly tile
/// allowance, attribution required). SATELLITE_TILE_URL overrides it with another provider.
const _arcgisKey = String.fromEnvironment('ARCGIS_API_KEY');
const _satelliteUrl = String.fromEnvironment('SATELLITE_TILE_URL');
const _satelliteAttribution = String.fromEnvironment('SATELLITE_TILE_ATTRIBUTION');
const esriImageryUrl = 'https://ibasemaps-api.arcgis.com/arcgis/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}?token=';
const esriImageryAttribution = 'Powered by Esri · Esri, Maxar, Earthstar Geographics, GIS User Community';

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
    this.cesiumIonToken = '',
  });

  factory AppConfig.fromEnvironment() => const AppConfig(
        apiBaseUrl: String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8000'),
        appToken: String.fromEnvironment('APP_TOKEN'),
        // OSM standard tiles: light use only, attribution required, no bulk/offline download.
        mapTileUrl: String.fromEnvironment('MAP_TILE_URL', defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
        mapTileAttribution: String.fromEnvironment('MAP_TILE_ATTRIBUTION', defaultValue: '© OpenStreetMap contributors'),
        // Satellite imagery is off unless a provider whose terms permit this use is configured.
        satelliteTileUrl: _satelliteUrl != '' ? _satelliteUrl : (_arcgisKey != '' ? '$esriImageryUrl$_arcgisKey' : ''),
        satelliteTileAttribution: _satelliteUrl != '' ? _satelliteAttribution : (_arcgisKey != '' ? esriImageryAttribution : ''),
        userAgentPackageName: 'org.factorycarbon.factory_carbon',
        // Cesium ion token for the 3D view (Google Photorealistic 3D Tiles and world imagery).
        cesiumIonToken: String.fromEnvironment('CESIUM_ION_TOKEN'),
      );

  final String apiBaseUrl;
  final String appToken;
  final String mapTileUrl;
  final String mapTileAttribution;
  final String satelliteTileUrl;
  final String satelliteTileAttribution;
  final String userAgentPackageName;
  final String cesiumIonToken;

  bool get hasSatellite => satelliteTileUrl.isNotEmpty;
  bool get has3d => cesiumIonToken.isNotEmpty;

  AppConfig withServer({String? apiBaseUrl, String? appToken}) => AppConfig(
        apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
        appToken: appToken ?? this.appToken,
        mapTileUrl: mapTileUrl,
        mapTileAttribution: mapTileAttribution,
        satelliteTileUrl: satelliteTileUrl,
        satelliteTileAttribution: satelliteTileAttribution,
        userAgentPackageName: userAgentPackageName,
        cesiumIonToken: cesiumIonToken,
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
