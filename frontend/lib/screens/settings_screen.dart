import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../l10n/strings_provider.dart';
import '../theme.dart';

class SettingsScreen extends StatefulWidget {
  final AppSettings settings;
  final ValueChanged<AppSettings> onChanged;

  const SettingsScreen(
      {super.key, required this.settings, required this.onChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _saved = false;
  late AppSettings _local;

  @override
  void initState() {
    super.initState();
    _local = widget.settings;
  }

  void _save() {
    setState(() => _saved = true);
    Future.delayed(
        const Duration(seconds: 2), () => setState(() => _saved = false));
  }

  void _update(AppSettings s) {
    setState(() => _local = s);
    widget.onChanged(s);
  }

  @override
  Widget build(BuildContext context) {
    final str = StringsProvider.of(context);
    final s = _local;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 740),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(str.get('settings_title'),
                  style: GoogleFonts.manrope(
                      fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(str.get('settings_sub'),
                  style: const TextStyle(fontSize: 13, color: kOnSurfaceMuted)),
              const SizedBox(height: 28),

              // Language (full width)
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel(Icons.language, str.get('settings_language')),
                    const SizedBox(height: 12),
                    DropdownButton<String>(
                      value: s.language,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(
                            value: 'en', child: Text('English (EN)')),
                        DropdownMenuItem(
                            value: 'es', child: Text('Español (ES)')),
                        DropdownMenuItem(
                            value: 'ca', child: Text('Català (CA)')),
                        DropdownMenuItem(
                            value: 'fr', child: Text('Français (FR)')),
                        DropdownMenuItem(
                            value: 'pt', child: Text('Português (PT)')),
                        DropdownMenuItem(
                            value: 'de', child: Text('Deutsch (DE)')),
                        DropdownMenuItem(value: 'ja', child: Text('日本語 (JA)')),
                      ],
                      onChanged: (v) => _update(s.copyWith(language: v)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Length + Model
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _sectionLabel(Icons.segment, str.get('settings_length')),
                              _badgeIndigo(s.length),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Slider(
                            value: ['concise', 'balanced', 'detailed']
                                .indexOf(s.length)
                                .toDouble(),
                            min: 0,
                            max: 2,
                            divisions: 2,
                            activeColor: kPrimary,
                            inactiveColor: kSurfaceHigh,
                            onChanged: (v) => _update(s.copyWith(
                                length: [
                              'concise',
                              'balanced',
                              'detailed'
                            ][v.round()])),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(str.get('concise'),
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: kOnSurfaceFaint,
                                      fontWeight: FontWeight.w700)),
                              Text(str.get('balanced'),
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: kOnSurfaceFaint,
                                      fontWeight: FontWeight.w700)),
                              Text(str.get('detailed'),
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: kOnSurfaceFaint,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionLabel(Icons.smart_toy, str.get('settings_model')),
                          const SizedBox(height: 12),
                          ...kModels.map((m) => _ModelCard(
                                model: m,
                                selected: s.model == m.id,
                                onTap: m.available
                                    ? () => _update(s.copyWith(model: m.id))
                                    : null,
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Toggles + Tone/Emoji
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionLabel(Icons.tune, str.get('settings_advanced')),
                          const SizedBox(height: 16),
                          ...[
                            _ToggleOpt(
                                'includeLicense',
                                str.get('settings_license'),
                                str.get('settings_license_sub'),
                                s.includeLicense),
                            _ToggleOpt(
                                'includeBadges',
                                str.get('settings_badges'),
                                str.get('settings_badges_sub'),
                                s.includeBadges),
                            _ToggleOpt(
                                'includeContributing',
                                str.get('settings_contributing'),
                                str.get('settings_contributing_sub'),
                                s.includeContributing),
                          ].map((opt) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(opt.label,
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600)),
                                          Text(opt.sub,
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: kOnSurfaceMuted)),
                                        ],
                                      ),
                                    ),
                                    Switch(
                                      value: opt.value,
                                      activeThumbColor: kPrimary,
                                      onChanged: (v) {
                                        if (opt.key == 'includeLicense') {
                                          _update(
                                              s.copyWith(includeLicense: v));
                                        } else if (opt.key == 'includeBadges') {
                                          _update(s.copyWith(includeBadges: v));
                                        } else {
                                          _update(s.copyWith(
                                              includeContributing: v));
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionLabel(Icons.record_voice_over, str.get('settings_tone')),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 6,
                            children: [
                              ['professional', str.get('professional')],
                              ['playful', str.get('playful')],
                              ['academic', str.get('academic')],
                            ]
                                .map((v) => _chip(v[1], s.tone == v[0],
                                    () => _update(s.copyWith(tone: v[0]))))
                                .toList(),
                          ),
                          const SizedBox(height: 20),
                          _sectionLabel(Icons.mood, str.get('settings_emojis')),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 6,
                            children: [
                              ['none', str.get('none')],
                              ['minimal', str.get('minimal')],
                              ['vibrant', str.get('vibrant')],
                            ]
                                .map((v) => _chip(v[1], s.emoji == v[0],
                                    () => _update(s.copyWith(emoji: v[0]))))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Save bar
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(colors: [kPrimary, kPrimaryDim]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(str.get('settings_save_title'),
                            style: GoogleFonts.manrope(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        Text(str.get('settings_save_sub'),
                            style:
                                const TextStyle(fontSize: 12, color: Colors.white60)),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _save,
                      icon: Icon(_saved ? Icons.check : Icons.save, size: 15),
                      label: Text(_saved ? str.get('settings_saved_btn') : str.get('settings_save_btn'),
                          style:
                              GoogleFonts.manrope(fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.12),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [kIslandShadow],
        ),
        child: child,
      );

  Widget _sectionLabel(IconData icon, String label) => Row(
        children: [
          Icon(icon, size: 16, color: kOnSurfaceMuted),
          const SizedBox(width: 6),
          Text(label.toUpperCase(),
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: kOnSurfaceMuted,
                  letterSpacing: 0.8)),
        ],
      );

  Widget _badgeIndigo(String label) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
          color: kAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(999)),
      child: Text(label,
          style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: kAccent,
              letterSpacing: 0.8)));

  Widget _chip(String label, bool active, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: active ? kPrimary : kSurfaceLow,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : kOnSurfaceMuted)),
        ),
      );
}

class _ToggleOpt {
  final String key;
  final String label;
  final String sub;
  final bool value;
  const _ToggleOpt(this.key, this.label, this.sub, this.value);
}

class _ModelCard extends StatelessWidget {
  final AiModel model;
  final bool selected;
  final VoidCallback? onTap;

  const _ModelCard({required this.model, required this.selected, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? kSurface : kSurfaceLow,
          border: Border.all(
              color: selected ? kPrimary : Colors.transparent, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(model.name,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color:
                              model.available ? kOnSurface : kOnSurfaceFaint)),
                  Text(model.sub,
                      style: const TextStyle(
                          fontSize: 11, color: kOnSurfaceFaint)),
                ],
              ),
            ),
            Icon(
              !model.available
                  ? Icons.lock
                  : selected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
              size: 16,
              color: selected && model.available ? kPrimary : kOnSurfaceFaint,
            ),
          ],
        ),
      ),
    );
  }
}
