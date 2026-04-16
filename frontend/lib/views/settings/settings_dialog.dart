import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/app_controller.dart';
import '../../core/app_colors.dart';
import '../../models/app_settings.dart';

/// View — SettingsDialog
/// Shown when the user taps Settings in the sidebar.
/// Reads/writes through AppController.
class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});
  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  static const _providers = {
    'grok':       'Grok (xAI)',
    'openai':     'OpenAI',
    'openrouter': 'OpenRouter (models gratuïts)',
  };
  static const _defaultModels = {
    'grok':       'grok-3-mini',
    'openai':     'gpt-4o-mini',
    'openrouter': 'google/gemma-3-27b-it:free',
  };

  late String _provider;
  late TextEditingController _apiKey;
  late TextEditingController _model;
  late TextEditingController _ghToken;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    final s = context.read<AppController>().settings;
    _provider = s.provider;
    _apiKey   = TextEditingController(text: s.apiKey);
    _model    = TextEditingController(text: s.model);
    _ghToken  = TextEditingController(text: s.githubToken);
  }

  @override
  void dispose() {
    _apiKey.dispose();
    _model.dispose();
    _ghToken.dispose();
    super.dispose();
  }

  void _save() {
    context.read<AppController>().updateSettings(AppSettings(
      provider:    _provider,
      apiKey:      _apiKey.text.trim(),
      model:       _model.text.trim(),
      githubToken: _ghToken.text.trim(),
    ));
    setState(() => _saved = true);
    Future.delayed(const Duration(seconds: 2),
        () { if (mounted) setState(() => _saved = false); });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    'Configuració',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.onSurfaceVariant,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Provider
              _FieldLabel('Proveïdor d\'IA'),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _provider,
                decoration: _inputDeco(),
                items: _providers.entries
                    .map((e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value, style: GoogleFonts.inter(fontSize: 13)),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    _provider  = v;
                    _model.text = _defaultModels[v] ?? '';
                  });
                },
              ),
              const SizedBox(height: 16),

              // API Key
              _FieldLabel('API Key'),
              const SizedBox(height: 6),
              _PassField(controller: _apiKey, hint: 'xai-…'),
              _Hint('Grok: console.x.ai  ·  OpenRouter: openrouter.ai (gratuït)'),
              const SizedBox(height: 16),

              // Model
              _FieldLabel('Model'),
              const SizedBox(height: 6),
              _TextField(controller: _model, hint: 'grok-3-mini'),
              _Hint('Grok: grok-3-mini  ·  OpenRouter gratuït: google/gemma-3-27b-it:free'),
              const SizedBox(height: 16),

              // GitHub token
              _FieldLabel('Token GitHub'),
              const SizedBox(height: 6),
              _PassField(controller: _ghToken, hint: 'ghp_…'),
              _Hint('Opcional. Puja el límit de 60 → 5000 req/hora.'),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Desar configuració',
                    style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              // Saved feedback
              AnimatedOpacity(
                opacity: _saved ? 1 : 0,
                duration: const Duration(milliseconds: 250),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Center(
                    child: Text(
                      'Desat correctament',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.green.shade600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco({String hint = ''}) => InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.inter(fontSize: 13, color: AppColors.outlineVariant),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: AppColors.outlineVariant.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
      );
}

// ── Small helpers ─────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurfaceVariant,
          letterSpacing: 0.05,
        ),
      );
}

class _Hint extends StatelessWidget {
  final String text;
  const _Hint(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(text,
            style: GoogleFonts.inter(
                fontSize: 11, color: AppColors.outlineVariant, height: 1.5)),
      );
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  const _TextField({required this.controller, required this.hint});
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface),
      decoration: _deco(hint),
    );
  }
}

class _PassField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  const _PassField({required this.controller, required this.hint});
  @override
  State<_PassField> createState() => _PassFieldState();
}

class _PassFieldState extends State<_PassField> {
  bool _obscure = true;
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface),
      decoration: _deco(widget.hint).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            size: 18, color: AppColors.outlineVariant,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}

InputDecoration _deco(String hint) => InputDecoration(
      hintText: hint,
      hintStyle:
          GoogleFonts.inter(fontSize: 13, color: AppColors.outlineVariant),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
            BorderSide(color: AppColors.outlineVariant.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      filled: true,
      fillColor: AppColors.surfaceContainerLow,
    );
