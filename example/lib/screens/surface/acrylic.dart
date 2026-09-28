import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../settings.dart';

class AcrylicPage extends StatefulWidget {
  const AcrylicPage({super.key});

  @override
  State<AcrylicPage> createState() => _AcrylicPageState();
}

class _AcrylicPageState extends State<AcrylicPage> with PageMixin {
  double tintOpacity = 0.8;
  double luminosityOpacity = 0.8;
  double blurAmount = kBlurAmount;
  double elevation = 0;
  Color? color;
  bool automaticLuminosity = true;
  bool acrylicDisabled = false;
  bool animateMaterial = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final customTint = color ?? theme.acrylicBackgroundColor;
    final luminosity = automaticLuminosity ? null : luminosityOpacity;

    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('Acrylic')),
      children: [
        const Text(
          'In-app Acrylic blurs Flutter content behind a clipped surface. This '
          'lab keeps the same high-contrast backdrop under every sample so the '
          'blur, luminosity, tint, noise, and solid fallback are easy to compare.',
        ),
        subtitle(content: const Text('Default materials')),
        const _MaterialComparison(
          children: [
            _MaterialSample(
              title: 'Acrylic',
              child: Stack(
                children: [
                  _AcrylicBackdropContent(),
                  Positioned.fill(child: Acrylic(child: SizedBox.expand())),
                ],
              ),
            ),
            _MaterialSample(
              title: 'Mica fallback',
              child: Stack(
                children: [
                  _AcrylicBackdropContent(),
                  Positioned.fill(child: Mica(child: SizedBox.expand())),
                ],
              ),
            ),
          ],
        ),
        subtitle(content: const Text('Acrylic rendering laboratory')),
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MaterialSample(
                title: 'Configured Acrylic',
                child: Stack(
                  children: [
                    const _AcrylicBackdropContent(),
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.all(12),
                        child: acrylicDisabled
                            ? DisableAcrylic(
                                child: Acrylic(
                                  fallbackColor: theme.acrylicFallbackColor,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  ),
                                  child: const SizedBox.expand(),
                                ),
                              )
                            : Acrylic(
                                tint: customTint,
                                tintAlpha: tintOpacity,
                                luminosityAlpha: luminosity,
                                blurAmount: blurAmount,
                                elevation: elevation,
                                fallbackColor: theme.acrylicFallbackColor,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                                child: const SizedBox.expand(),
                              ),
                      ),
                    ),
                    const Positioned.fill(
                      child: IgnorePointer(
                        child: Padding(
                          padding: EdgeInsetsDirectional.all(28),
                          child: Align(
                            alignment: AlignmentDirectional.topStart,
                            child: Text(
                              'Foreground content remains above the material',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 24,
                runSpacing: 12,
                children: [
                  InfoLabel(
                    label: 'Tint color',
                    child: ComboBox<Color>(
                      value: color,
                      placeholder: const Text('Theme tint'),
                      onChanged: (value) => setState(() => color = value),
                      items: [
                        ...Colors.accentColors.map(
                          (accent) => ComboBoxItem(
                            value: accent,
                            child: Text(
                              accentColorNames[Colors.accentColors.indexOf(
                                    accent,
                                  ) +
                                  1],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  InfoLabel(
                    label: 'Tint opacity: ${tintOpacity.toStringAsFixed(2)}',
                    child: SizedBox(
                      width: 180,
                      child: Slider(
                        value: tintOpacity,
                        max: 1,
                        onChanged: (value) =>
                            setState(() => tintOpacity = value),
                      ),
                    ),
                  ),
                  InfoLabel(
                    label:
                        'Luminosity opacity: ${luminosityOpacity.toStringAsFixed(2)}',
                    child: SizedBox(
                      width: 180,
                      child: Slider(
                        value: luminosityOpacity,
                        max: 1,
                        onChanged: automaticLuminosity
                            ? null
                            : (value) =>
                                  setState(() => luminosityOpacity = value),
                      ),
                    ),
                  ),
                  InfoLabel(
                    label: 'Blur: ${blurAmount.toStringAsFixed(0)}',
                    child: SizedBox(
                      width: 180,
                      child: Slider(
                        value: blurAmount,
                        max: 60,
                        onChanged: (value) =>
                            setState(() => blurAmount = value),
                      ),
                    ),
                  ),
                  InfoLabel(
                    label: 'Elevation: ${elevation.toStringAsFixed(0)}',
                    child: SizedBox(
                      width: 180,
                      child: Slider(
                        value: elevation,
                        max: 20,
                        onChanged: (value) => setState(() => elevation = value),
                      ),
                    ),
                  ),
                  Checkbox(
                    checked: automaticLuminosity,
                    onChanged: (value) =>
                        setState(() => automaticLuminosity = value ?? true),
                    content: const Text('Automatic luminosity'),
                  ),
                  Checkbox(
                    checked: acrylicDisabled,
                    onChanged: (value) =>
                        setState(() => acrylicDisabled = value ?? false),
                    content: const Text('Disable Acrylic / fallback'),
                  ),
                ],
              ),
            ],
          ),
        ),
        subtitle(content: const Text('Animated Acrylic')),
        Card(
          child: Row(
            children: [
              Expanded(
                child: _MaterialSample(
                  title: 'Animation keeps the same material pipeline',
                  child: Stack(
                    children: [
                      const _AcrylicBackdropContent(),
                      Positioned.fill(
                        child: AnimatedAcrylic(
                          duration: const Duration(milliseconds: 500),
                          tint: animateMaterial ? Colors.blue : Colors.magenta,
                          tintAlpha: animateMaterial ? 0.1 : 0.8,

                          blurAmount: animateMaterial ? 45 : 20,
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Button(
                onPressed: () =>
                    setState(() => animateMaterial = !animateMaterial),
                child: Text(animateMaterial ? 'Reverse' : 'Animate'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MaterialComparison extends StatelessWidget {
  const _MaterialComparison({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 16, runSpacing: 16, children: children);
  }
}

class _MaterialSample extends StatelessWidget {
  const _MaterialSample({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 420,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: 8),
            child: Text(
              title,
              style: FluentTheme.of(context).typography.bodyStrong,
            ),
          ),
          SizedBox(height: 220, child: child),
        ],
      ),
    );
  }
}

class _AcrylicBackdropContent extends StatelessWidget {
  const _AcrylicBackdropContent();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            Color(0xFF080808),
            Color(0xFFEEEEEE),
            Color(0xFF0078D4),
            Color(0xFFE81123),
          ],
          stops: [0, 0.32, 0.66, 1],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _ContrastStripePainter()),
          Align(
            alignment: AlignmentDirectional.center,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.yellow,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.8),
                    blurRadius: 18,
                    offset: const Offset(8, 8),
                  ),
                ],
              ),
              child: const Padding(
                padding: EdgeInsetsDirectional.all(12),
                child: Text(
                  'Readable text\nsharp contrast + shadow',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const PositionedDirectional(
            start: 12,
            bottom: 12,
            child: Text(
              'colorful backdrop',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContrastStripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.24);
    for (var x = -size.height; x < size.width; x += 24) {
      canvas.drawRect(Rect.fromLTWH(x, 0, 10, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ContrastStripePainter oldDelegate) => false;
}
