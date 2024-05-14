import 'package:cached_network_image/cached_network_image.dart';
import 'package:figma_frame_inspector/src/figmat_rest_api.dart';
import 'package:flutter/material.dart';

enum StackOrder { childOnTop, figmaFrameOnTop }

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
  /// Child widget which will be rendered on bellow of the Figma frame.
  ///
  final Widget child;

  ///
  /// Alignment of the Figma frame on the screen.
  ///
  final AlignmentDirectional alignment;

  ///
  /// Opacity notifier for the Figma frame.
  ///
  final ValueNotifier<double>? opacityNotifier;

  ///
  /// Stack order of the Figma frame and child widget. Default is `StackOrder.figmaFrameOnTop`.
  ///
  final StackOrder stackOrder;

  ///
  /// Creates [FigmaFrameInspector] widget.
  ///
  const FigmaFrameInspector({
    Key? key,
    required this.frameUrl,
    required this.figmaToken,
    this.scale = 1,
    this.initialOpacity = .3,
    this.enabled = true,
    this.alignment = AlignmentDirectional.topEnd,
    this.opacityNotifier,
    this.stackOrder = StackOrder.figmaFrameOnTop,
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
          if (widget.stackOrder == StackOrder.figmaFrameOnTop) widget.child,
          CachedNetworkImage(
            imageUrl: _imageUrl!,
            width: MediaQuery.of(context).size.width,
            imageBuilder: (context, imageProvider) => Opacity(
              opacity: widget.opacityNotifier?.value ?? widget.initialOpacity,
              child: Image(image: imageProvider),
            ),
          ),
          if (widget.stackOrder == StackOrder.childOnTop) widget.child,
        ],
      );
    } else {
      return widget.child;
    }
  }
}
