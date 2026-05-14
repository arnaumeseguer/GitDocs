class AiModel {
  final String id;
  final String name;
  final String sub;
  final bool available;

  const AiModel({
    required this.id,
    required this.name,
    required this.sub,
    required this.available,
  });
}

class Template {
  final String id;
  final String icon;
  final String label;
  final String desc;

  const Template({
    required this.id,
    required this.icon,
    required this.label,
    required this.desc,
  });
}

class AppSettings {
  final String length;
  final String tone;
  final String emoji;
  final String template;
  final String language;
  final String model;
  final bool includeLicense;
  final bool includeBadges;
  final bool includeContributing;

  const AppSettings({
    this.length = 'balanced',
    this.tone = 'professional',
    this.emoji = 'minimal',
    this.template = 'standard',
    this.language = 'en',
    this.model = 'gemini',
    this.includeLicense = true,
    this.includeBadges = true,
    this.includeContributing = true,
  });

  AppSettings copyWith({
    String? length,
    String? tone,
    String? emoji,
    String? template,
    String? language,
    String? model,
    bool? includeLicense,
    bool? includeBadges,
    bool? includeContributing,
  }) {
    return AppSettings(
      length: length ?? this.length,
      tone: tone ?? this.tone,
      emoji: emoji ?? this.emoji,
      template: template ?? this.template,
      language: language ?? this.language,
      model: model ?? this.model,
      includeLicense: includeLicense ?? this.includeLicense,
      includeBadges: includeBadges ?? this.includeBadges,
      includeContributing: includeContributing ?? this.includeContributing,
    );
  }

  Map<String, dynamic> toJson() => {
        'length': length,
        'tone': tone,
        'emoji': emoji,
        'template': template,
        'language': language,
        'model': model,
        'includeLicense': includeLicense,
        'includeBadges': includeBadges,
        'includeContributing': includeContributing,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        length: json['length'] ?? 'balanced',
        tone: json['tone'] ?? 'professional',
        emoji: json['emoji'] ?? 'minimal',
        template: json['template'] ?? 'standard',
        language: json['language'] ?? 'en',
        model: json['model'] ?? 'gemini',
        includeLicense: json['includeLicense'] ?? true,
        includeBadges: json['includeBadges'] ?? true,
        includeContributing: json['includeContributing'] ?? true,
      );
}

class HistoryItem {
  final String readme;
  final Map<String, dynamic> repoData;
  final Map<String, dynamic> langData;
  final AppSettings settings;
  final String url;
  final int timestamp;
  final String aiModel;

  const HistoryItem({
    required this.readme,
    required this.repoData,
    required this.langData,
    required this.settings,
    required this.url,
    required this.timestamp,
    this.aiModel = 'gemini',
  });

  Map<String, dynamic> toJson() => {
        'readme': readme,
        'repoData': repoData,
        'langData': langData,
        'settings': settings.toJson(),
        'url': url,
        'timestamp': timestamp,
        'aiModel': aiModel,
      };

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
        readme: json['readme'] ?? '',
        repoData: Map<String, dynamic>.from(json['repoData'] ?? {}),
        langData: Map<String, dynamic>.from(json['langData'] ?? {}),
        settings: AppSettings.fromJson(
            Map<String, dynamic>.from(json['settings'] ?? {})),
        url: json['url'] ?? '',
        timestamp: json['timestamp'] ?? 0,
        aiModel: json['aiModel'] ?? 'gemini',
      );
}

const kModels = [
  AiModel(
      id: 'gemini',
      name: 'Gemini 2.5 Flash',
      sub: 'Google · Activo',
      available: true),
  AiModel(
      id: 'grok',
      name: 'Grok-3',
      sub: 'X.AI · Activo',
      available: true),
  AiModel(
      id: 'claude',
      name: 'Claude Haiku',
      sub: 'Anthropic · Activo',
      available: true),
  AiModel(
      id: 'gpt4',
      name: 'GPT-4 Turbo',
      sub: 'OpenAI · Próximamente',
      available: false),
  AiModel(
      id: 'llama',
      name: 'Llama 3',
      sub: 'Meta · Próximamente',
      available: false),
];

const kTemplates = [
  Template(
      id: 'standard',
      icon: 'description',
      label: 'Estándar',
      desc: 'README completo con todas las secciones esenciales.'),
  Template(
      id: 'minimal',
      icon: 'minimize',
      label: 'Minimalista',
      desc: 'Solo lo esencial: qué es, cómo instalarlo y usarlo.'),
  Template(
      id: 'library',
      icon: 'library_books',
      label: 'Librería / SDK',
      desc: 'API reference, ejemplos de código, badges de versión.'),
  Template(
      id: 'cli',
      icon: 'terminal',
      label: 'CLI Tool',
      desc: 'Comandos, flags, ejemplos de uso en terminal.'),
  Template(
      id: 'saas',
      icon: 'cloud',
      label: 'SaaS / App Web',
      desc: 'Demo gif, features, pricing, screenshots.'),
  Template(
      id: 'research',
      icon: 'science',
      label: 'Investigación',
      desc: 'Abstract, metodología, citas, resultados.'),
];
