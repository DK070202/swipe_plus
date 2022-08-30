import 'package:flutter/material.dart';

/// Default value for reverse animation duration of widget translation.
const _kReverseDuration = Duration(milliseconds: 150);

/// Default value for threshold percentage.
const _kMaxTranslation = .3;

/// Default value for min translation threshold.
const _kMinDragThreshold = .70;

class DragAndSwipe extends StatefulWidget {
  const DragAndSwipe({
    super.key,
    required this.child,
    this.onDragComplete,
    this.onDragCancel,
    this.alignment = Alignment.centerRight,
    this.reverseDuration = _kReverseDuration,
    this.maxTranslation = _kMaxTranslation,
    this.minThreshold = _kMinDragThreshold,
  }) : assert(maxTranslation != 0);

  /// A call back for swipe completion.
  ///
  /// When horizontal drag is enough to cross [minThreshold] then it will called.
  final VoidCallback? onDragComplete;

  /// A call back for drag cancel.
  ///
  /// When horizontal drag is not enough to cross [minThreshold] and call back
  /// canceled from user.
  final VoidCallback? onDragCancel;

  /// For aligning child.
  ///
  /// This widget uses [Align] internally to set Alignment of Widget and widget
  /// can be available better to the hitTest/GestureRecognition.
  final Alignment alignment;

  /// Value of percentage translation of child to call [onDragComplete].
  final double maxTranslation;

  /// Duration for reverse translation.
  final Duration reverseDuration;

  /// A percentage that defines minThreshold for calling [onDragComplete].
  final double minThreshold;

  /// Proxy widget.
  final Widget child;

  @override
  State<DragAndSwipe> createState() => _DragAndSwipeState();
}

class _DragAndSwipeState extends State<DragAndSwipe>
    with SingleTickerProviderStateMixin {
  /// Controller for [swipeTween].
  AnimationController? animationController;

  /// The Tween for translation animation.
  Animation<double>? swipeTween;

  /// Key for mapping size of [RenderBox].
  final GlobalKey sizeMapperKey = GlobalKey(debugLabel: 'SizeMapper');

  /// The size of the child.
  Size size = Size.zero;

  /// The amount horizontal translation.
  double shiftedOffset = 0;

  @override
  void initState() {
    super.initState();
    setupAnimationController();
    setupTween();
  }

  @override
  void didUpdateWidget(covariant DragAndSwipe oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.maxTranslation != oldWidget.maxTranslation) setupTween();
    if (widget.reverseDuration != oldWidget.reverseDuration) {
      setupAnimationController();
    }
  }

  @override
  void dispose() {
    animationController!.dispose();
    super.dispose();
  }

  /// Assigns and updates the [AnimationController] to [animationController].
  ///
  /// The value of [DragAndSwipe.reverseDuration] might be change and in that
  /// case it will update the animationController.
  void setupAnimationController() {
    animationController = AnimationController(
      vsync: this,
      reverseDuration: widget.reverseDuration,
    );
  }

  /// Creates tween.
  ///
  /// When value of animation is 1, at that time the value of tween will
  /// [DragAndSwipe.maxTranslation] this plays trick for dragging defined
  /// percentage of child.
  void setupTween() {
    assert(animationController != null,
        'Initialize animation controller before setting up tween.');
    swipeTween = Tween<double>(begin: 0, end: widget.maxTranslation).animate(
      CurvedAnimation(
        parent: animationController!,
        curve: const Cubic(0, .78, 1, .99),
      ),
    );
  }

  /// Maps child dimension with help of [sizeMapperKey].
  ///
  /// Calculates the child dimension after after build method.
  void mapChidDimension() {
    final box = sizeMapperKey.currentContext!.findRenderObject() as RenderBox;
    size = box.size;
  }

  /// Updates the value [shiftedOffset] and [animationController].
  ///
  /// Updates the animationController in relative to the size of child. When we
  /// will drag it horizontally and when value of [shiftedOffset] is equal to
  /// the width of the provided child. At that moment the amount of translation
  /// will be the 1/[DragAndSwipe.maxTranslation] of the width of child.
  void onHorizontalDragUpdate(DragUpdateDetails details) {
    mapChidDimension();
    shiftedOffset += details.delta.dx;
    animationController!.value = shiftedOffset / size.width;
  }

  /// Resets [shiftedOffset],reverses the [swipeTween] and after completing it
  /// calls [onReset] callback.
  void resetValues(VoidCallback? onReset) {
    shiftedOffset = 0;
    animationController!.reverse().then((value) {
      onReset?.call();
    });
  }

  /// Calls the completion callback provided from the [widget] when it passes
  /// threshold value of dragging.
  void onMatchThreshold() {
    resetValues(() {
      widget.onDragComplete?.call();
    });
  }

  /// Call the cancellation callback when the drag interaction is not enough
  /// for threshold.
  void onDidNotMatchThreshold() {
    resetValues(() {
      widget.onDragCancel?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: onHorizontalDragUpdate,
      onHorizontalDragEnd: (details) {
        if (animationController!.value > widget.minThreshold) {
          onMatchThreshold();
        } else {
          onDidNotMatchThreshold();
        }
      },
      child: AnimatedBuilder(
        animation: swipeTween!,

        // For avoid rebuilding in subtree.
        builder: (context, child) => Transform.translate(
          offset: Offset(swipeTween!.value * size.width, 0),
          child: child,
        ),

        // For better hit test.
        child: Container(
          color: Colors.transparent,
          width: double.infinity,
          child: Align(
            alignment: widget.alignment,

            // For mapping chid dimension.
            child: KeyedSubtree(
              key: sizeMapperKey,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
