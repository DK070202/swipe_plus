import 'package:flutter/material.dart';

/// Drag directions.
enum DragDirection {
  /// For left to right drag.
  LTR,

  /// For right to left drag.
  RTL,
}

/// Default value for reverse animation duration of widget translation.
const _kReverseDuration = Duration(milliseconds: 150);

/// Default value for threshold percentage.
const _kMaxTranslation = .3;

/// Default value for min translation threshold.
const _kMinDragThreshold = .70;

class SwipePlus extends StatefulWidget {
  const SwipePlus({
    super.key,
    required this.child,
    this.onDragComplete,
    this.onDragCancel,
    this.alignment = Alignment.centerRight,
    this.reverseDuration = _kReverseDuration,
    this.maxTranslation = _kMaxTranslation,
    this.minThreshold = _kMinDragThreshold,
    this.dragDirection = DragDirection.LTR,
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
  /// This uses [Align] and [ColoredBox] internally to set Alignment of Widget
  /// so, the complete area of widget including whitespace can be available for
  /// hit-test.
  final Alignment alignment;

  /// It decides the drag direction of child.
  ///
  /// * If [DragDirection.RTL] then it can dragged from right side to left side.
  /// * If [DragDirection.LTR] then it can be dragged from left to to right.
  final DragDirection dragDirection;

  /// Value of width percentage,for max translation in direction.
  ///
  /// It defines bounds of translation in direction. If it is set to .3 then at
  /// max drag you will able to translate 30% of [child] size in any direction.
  final double maxTranslation;

  /// Duration for reverse translation.
  ///
  /// If drag not completes or if it not crosses the [minThreshold] percentage
  /// of width then it play reverse animation with [reverseDuration] duration.
  final Duration reverseDuration;

  /// A percentage of minThreshold for calling [onDragComplete].
  ///
  /// It helps to define boundary for calling [onDragComplete]. If it is set
  /// to .2 and the value of [maxTranslation] is set to .3 then if we leave drag
  /// drag handle at grater than 15% of translation it will consider this action
  /// as threshold.
  final double minThreshold;

  /// Proxy widget.
  final Widget child;

  @override
  State<SwipePlus> createState() => _SwipePlusState();
}

class _SwipePlusState extends State<SwipePlus>
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
  void didUpdateWidget(covariant SwipePlus oldWidget) {
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
  /// The value of [SwipePlus.reverseDuration] might be change and in that
  /// case it will update the animationController.
  void setupAnimationController() {
    animationController = AnimationController(
      vsync: this,
      reverseDuration: widget.reverseDuration,
    );
  }

  /// Calculate maxTranslation according direction.
  double getMaxTranslation(DragDirection dragDirection) {
    switch (dragDirection) {
      case DragDirection.RTL:
        return -widget.maxTranslation;
      case DragDirection.LTR:
        return widget.maxTranslation;
    }
  }

  /// Creates tween.
  ///
  /// When value of animation is 1, at that time the value of tween will
  /// [SwipePlus.maxTranslation] this plays trick for dragging defined
  /// percentage of child.
  void setupTween() {
    assert(animationController != null,
        'Initialize animation controller before setting up tween.');
    final maxTranslation = getMaxTranslation(widget.dragDirection);
    swipeTween = Tween<double>(begin: 0, end: maxTranslation).animate(
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
  /// will be the 1/[SwipePlus.maxTranslation] of the width of child.
  ///
  /// If direction is [DragDirection.RTL], then it will convert shiftedOffset
  /// into positive by subtracting it.
  void onHorizontalDragUpdate(DragUpdateDetails details) {
    mapChidDimension();
    switch (widget.dragDirection) {
      case DragDirection.RTL:
        shiftedOffset -= details.delta.dx;
        break;
      case DragDirection.LTR:
        shiftedOffset += details.delta.dx;
        break;
    }
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

  /// Decides the completion of the action. At the moment of drag completion
  ///  if the value of [animationController] is greater than value of
  /// [SwipePlus.minThreshold] then it will call [onMatchThreshold] call back
  /// else [onDidNotMatchThreshold].
  void onDragComplete(DragEndDetails details) {
    if (animationController!.value > widget.minThreshold) {
      onMatchThreshold();
    } else {
      onDidNotMatchThreshold();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: onHorizontalDragUpdate,
      onHorizontalDragEnd: onDragComplete,
      child: AnimatedBuilder(
        animation: swipeTween!,

        // For avoid rebuilding in subtree.
        builder: (context, child) => Transform.translate(
          offset: Offset(swipeTween!.value * size.width, 0),
          child: child,
        ),

        // For better hit test.
        child: ColoredBox(
          color: Colors.transparent,
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
