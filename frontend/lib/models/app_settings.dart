/// Model — AppSettings
class AppSettings {
  final String provider;
  final String apiKey;
  final String model;
  final String githubToken;

  const AppSettings({
    this.provider    = 'grok',
    this.apiKey      = '',
    this.model       = 'grok-3-mini',
    this.githubToken = '',
  });

  AppSettings copyWith({
    String? provider,
    String? apiKey,
    String? model,
    String? githubToken,
  }) =>
      AppSettings(
        provider:    provider    ?? this.provider,
        apiKey:      apiKey      ?? this.apiKey,
        model:       model       ?? this.model,
        githubToken: githubToken ?? this.githubToken,
      );

  Map<String, dynamic> toJson() => {
        'provider':    provider,
        'apiKey':      apiKey,
        'model':       model,
        'githubToken': githubToken,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        provider:    json['provider']    as String? ?? 'grok',
        apiKey:      json['apiKey']      as String? ?? '',
        model:       json['model']       as String? ?? 'grok-3-mini',
        githubToken: json['githubToken'] as String? ?? '',
      );
}
