import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../l10n/strings_provider.dart';
import '../theme.dart';

class TemplatesScreen extends StatelessWidget {
  final ValueChanged<String> onSelectTemplate;

  const TemplatesScreen({super.key, required this.onSelectTemplate});

  static final _iconMap = {
    'description': Icons.description,
    'minimize': Icons.minimize,
    'library_books': Icons.library_books,
    'terminal': Icons.terminal,
    'cloud': Icons.cloud,
    'science': Icons.science,
  };

  @override
  Widget build(BuildContext context) {
    final s = StringsProvider.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.get('templates_title'),
                  style: GoogleFonts.manrope(
                      fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(s.get('templates_sub'),
                  style: const TextStyle(fontSize: 13, color: kOnSurfaceMuted)),
              const SizedBox(height: 28),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.6,
                ),
                itemCount: kTemplates.length,
                itemBuilder: (_, i) =>
                    _TemplateCard(
                      template: kTemplates[i],
                      iconData: _iconMap[kTemplates[i].icon] ?? Icons.article,
                      onTap: () => onSelectTemplate(kTemplates[i].id),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TemplateCard extends StatefulWidget {
  final Template template;
  final IconData iconData;
  final VoidCallback onTap;

  const _TemplateCard(
      {required this.template,
      required this.iconData,
      required this.onTap});

  @override
  State<_TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends State<_TemplateCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [_hovered ? kIslandShadowHover : kIslandShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                        color: kSurfaceLow,
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(widget.iconData,
                        size: 20, color: kPrimary),
                  ),
                  const SizedBox(width: 12),
                  Text(widget.template.label,
                      style: GoogleFonts.manrope(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Text(widget.template.desc,
                    style: const TextStyle(
                        fontSize: 13, color: kOnSurfaceMuted, height: 1.5),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3),
              ),
              Row(
                children: [
                  Text(StringsProvider.of(context).get('templates_use'),
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: kAccent)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 14, color: kAccent),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
