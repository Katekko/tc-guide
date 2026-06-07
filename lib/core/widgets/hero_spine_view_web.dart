import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

/// Web implementation: embeds the vendored Spine 3.8 player in an `<iframe>`.
///
/// The iframe (and therefore the heavy textures) is only created when this
/// widget is built — i.e. when the user opens the hero's page — so it is
/// effectively lazy-loaded per hero.
class HeroSpineView extends StatefulWidget {
  /// Creates a live hero animation view for [heroId].
  const HeroSpineView({
    super.key,
    required this.heroId,
    this.height = 420,
    this.animation,
  });

  /// TC hero id, e.g. `'55007'` for Jeanne.
  final String heroId;

  /// Height of the animation box in logical pixels.
  final double height;

  /// Optional animation clip name to force (defaults to Idle in the player).
  final String? animation;

  @override
  State<HeroSpineView> createState() => _HeroSpineViewState();
}

// platformViewRegistry refuses to register the same viewType twice.
final Set<String> _registeredViewTypes = <String>{};

class _HeroSpineViewState extends State<HeroSpineView> {
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    final anim = widget.animation == null ? '' : '&anim=${widget.animation}';
    _viewType = 'hero-spine-${widget.heroId}-${widget.animation ?? 'idle'}';

    if (_registeredViewTypes.add(_viewType)) {
      ui_web.platformViewRegistry.registerViewFactory(_viewType, (int _) {
        final iframe = web.HTMLIFrameElement()
          ..src = '/spine_viewer.html?hero=${widget.heroId}$anim'
          ..title = 'Hero ${widget.heroId} animation'
          ..loading = 'lazy';
        iframe.style
          ..border = '0'
          ..width = '100%'
          ..height = '100%'
          ..backgroundColor = 'transparent';
        return iframe;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: HtmlElementView(viewType: _viewType),
    );
  }
}
