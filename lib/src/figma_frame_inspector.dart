import 'package:cached_network_image/cached_network_image.dart';
import 'package:figma_frame_inspector/src/figmat_rest_api.dart';
import 'package:flutter/material.dart';

///
/// Widget which renders provided Figma frame on top of screen widget.
///
class FigmaFrameInspector extends StatefulWidget {
  ///
  /// A link to Figma frame.
  ///
  /// It should be in format: `https://www.figma.com/file/<file_key>/<file_name >?node-id=<node_id>`.
  ///
  final String frameUrl;

  ///
  /// Figma `Personal access token` from Account Settings page.
  ///
  final String figmaToken;

  ///
  /// A number between `0.01` and `4`, the image scaling factor (basically resolution of frame image).
  ///
  final double scale;

  ///
  /// Opacity of the frame on the screen start (default `30%`).
  ///
  final double initialOpacity;

  ///
  /// Enable or disable the frame overlay (default `true`).
  ///
  final bool enabled;

  ///
  /// Enable or disable vertical scroll to change the frame overlay opacity (default `true`).
  ///
  final bool isTouchToChangeOpacityEnabled;

  ///
  /// Child widget which will be rendered on bellow of the Figma frame.
  ///
  final Widget child;

  final AlignmentDirectional alignment;

  final ValueNotifier<double>? opacityNotifier;

  ///
  /// Creates [FigmaFrameInspector] widget.
  ///
  const FigmaFrameInspector({
    Key? key,
    required this.frameUrl,
    required this.figmaToken,
    this.scale = 3,
    this.initialOpacity = .3,
    this.enabled = true,
    this.isTouchToChangeOpacityEnabled = true,
    this.alignment = AlignmentDirectional.topEnd,
    this.opacityNotifier,
    required this.child,
  }) : super(key: key);

  @override
  State<FigmaFrameInspector> createState() => _FigmaFrameInspectorState();
}

class _FigmaFrameInspectorState extends State<FigmaFrameInspector> {
  String? _imageUrl;

  @override
  void initState() {
    super.initState();

    FigmaRestApi.downloadFrameImage(
      figmatToken: widget.figmaToken,
      figmaframeUrl: widget.frameUrl,
      imageScale: widget.scale,
    ).then((value) => setState(() => _imageUrl = value));
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    if (_imageUrl != null) {
      return Stack(
        alignment: widget.alignment,
        children: <Widget>[
          widget.child,
          FigmaImageContainer(
            isTouchToChangeOpacityEnabled: widget.isTouchToChangeOpacityEnabled,
            initialOpacity: widget.initialOpacity,
            opacityNotifier: widget.opacityNotifier,
            figmaImageUrl: _imageUrl!,
          )
        ],
      );
    } else {
      return widget.child;
    }
  }
}

class FigmaImageContainer extends StatelessWidget {
  final String figmaImageUrl;
  final double initialOpacity;
  final bool isTouchToChangeOpacityEnabled;
  final ValueNotifier<double>? opacityNotifier;

  const FigmaImageContainer({
    Key? key,
    required this.figmaImageUrl,
    required this.initialOpacity,
    required this.isTouchToChangeOpacityEnabled,
    this.opacityNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: figmaImageUrl,
      width: MediaQuery.of(context).size.width,
      imageBuilder: (context, imageProvider) => _DynamicOpacity(
        opacityNotifier: opacityNotifier ?? ValueNotifier(1.0),
        child: Image(image: imageProvider),
      ),
    );
  }
}

class _DynamicOpacity extends StatelessWidget {
  final ValueNotifier opacityNotifier;
  final Widget child;

  const _DynamicOpacity({
    Key? key,
    required this.opacityNotifier,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacityNotifier.value,
      child: child,
    );
  }
}
