import 'package:cached_network_image/cached_network_image.dart';
import 'package:figma_frame_inspector/src/figmat_rest_api.dart';
import 'package:flutter/material.dart';

enum ChildDisplayType {
  disabled,
  stackedChildOnTop,
  stackedChildOnBottom,
  rowChildOnLeft,
  rowChildOnRight,
  columnChildOnTop,
  columnChildOnBottom,
}

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
  /// Child widget which will be rendered on bellow of the Figma frame.
  ///
  final Widget child;

  ///
  /// Opacity notifier for the Figma frame.
  ///
  final ValueNotifier<double>? opacityNotifier;

  ///
  /// Stack order of the Figma frame and child widget.
  ///
  final ChildDisplayType childDisplayType;

  ///
  /// Creates [FigmaFrameInspector] widget.
  ///
  const FigmaFrameInspector({
    Key? key,
    required this.frameUrl,
    required this.figmaToken,
    this.scale = 1,
    this.initialOpacity = .3,
    this.opacityNotifier,
    this.childDisplayType = ChildDisplayType.stackedChildOnTop,
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
    if (widget.childDisplayType == ChildDisplayType.disabled || _imageUrl == null) {
      return widget.child;
    }

    final figmaWidget = CachedNetworkImage(
      imageUrl: _imageUrl!,
      width: MediaQuery.of(context).size.width,
      imageBuilder: (context, imageProvider) => Transform.scale(
        scale: widget.scale,
        child: Opacity(
          opacity: widget.opacityNotifier?.value ?? widget.initialOpacity,
          child: Image(image: imageProvider),
        ),
      ),
    );

    bool useStack = false;
    bool useRow = false;
    bool useColumn = false;

    switch (widget.childDisplayType) {
      case ChildDisplayType.stackedChildOnTop:
      case ChildDisplayType.stackedChildOnBottom:
        useStack = true;
        break;
      case ChildDisplayType.rowChildOnLeft:
      case ChildDisplayType.rowChildOnRight:
        useRow = true;
        break;
      case ChildDisplayType.columnChildOnTop:
      case ChildDisplayType.columnChildOnBottom:
        useColumn = true;
        break;
      default:
    }

    if (useStack) {
      return Stack(
        alignment: Alignment.center,
        children: <Widget>[
          if (widget.childDisplayType == ChildDisplayType.stackedChildOnBottom) widget.child,
          figmaWidget,
          if (widget.childDisplayType == ChildDisplayType.stackedChildOnTop) widget.child,
        ],
      );
    }

    if (useRow) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (widget.childDisplayType == ChildDisplayType.rowChildOnLeft) widget.child,
          figmaWidget,
          if (widget.childDisplayType == ChildDisplayType.rowChildOnRight) widget.child,
        ],
      );
    }

    if (useColumn) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (widget.childDisplayType == ChildDisplayType.columnChildOnTop) widget.child,
          figmaWidget,
          if (widget.childDisplayType == ChildDisplayType.columnChildOnBottom) widget.child,
        ],
      );
    }

    return widget.child;
  }
}
