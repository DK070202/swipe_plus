import 'package:flutter/material.dart';

class DragAndSwipe extends StatefulWidget {
  const DragAndSwipe(
      {Key? key,
      required this.child,
      this.onLeftSwipeComplete,
      this.onLeftSwipeCancel,
      this.alignment = Alignment.centerRight})
      : super(key: key);
  final Widget child;
  final VoidCallback? onLeftSwipeComplete;
  final VoidCallback? onLeftSwipeCancel;
  final Alignment alignment;

  @override
  State<DragAndSwipe> createState() => _DragAndSwipeState();
}

class _DragAndSwipeState extends State<DragAndSwipe>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  late final GlobalKey sizeMapperKey;
  late final Animation<double> swipeTween;
  Size size = Size.zero;
  double shiftedOffset = 0;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        vsync: this,
        lowerBound: 0,
        upperBound: .5,
        reverseDuration: const Duration(milliseconds: 150));
    swipeTween = Tween<double>(begin: 0, end: .5).animate(CurvedAnimation(
      parent: animationController,
      curve: const Cubic(0, .78, 1, .99),
    ));
    sizeMapperKey = GlobalKey(debugLabel: 'SizeMapper');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) {
      final box = sizeMapperKey.currentContext!.findRenderObject() as RenderBox;
      size = box.size;
    });
  }

  void onHorizontalDragUpdate(DragUpdateDetails details) {
    shiftedOffset += details.delta.dx;
    animationController.value = shiftedOffset / size.width;
  }

  void onMatchThreshold() {
    shiftedOffset = 0;
    animationController.reverse().then((value) {
      widget.onLeftSwipeComplete?.call();
    });
  }

  void onDidNotMatchThreshold() {
    shiftedOffset = 0;
    animationController.reverse().then((value) {
      widget.onLeftSwipeCancel?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: onHorizontalDragUpdate,
      onHorizontalDragEnd: (details) {
        if (animationController.status == AnimationStatus.completed) {
          onMatchThreshold();
        } else {
          onDidNotMatchThreshold();
        }
      },
      child: AnimatedBuilder(
        animation: swipeTween,

        /// For avoid rebuilding whole subtree.
        builder: (context, child) => Transform.translate(
          offset: Offset(swipeTween.value * size.width, 0),
          child: child,
        ),

        /// For better hit test.
        child: Container(
          color: Colors.transparent,
          width: double.infinity,
          child: Align(
            alignment: widget.alignment,

            /// For mapping chid dimension.
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
