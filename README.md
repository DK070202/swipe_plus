# Swipe Plus.

## For creating a message drag effect.


<img src="https://user-images.githubusercontent.com/78605453/200184431-df6342f2-969b-476e-b1b8-64a747936601.gif" width="256" height="512" title="Swipe To iOS Output">




## Installation
```yaml
  swipe_plus:
    git:
      url: https://github.com/DK070202/drag_and_swipe.git
      ref: master
```


## Usage.

Wrap your widget with SwipePlus and provide onDragComplete and/or onDragCancel callback.

```dart
SwipePlus(
    child: someWidget,
    onDragComplete: (){
        /// TODO : Reply to message.
    }
)
```

## Available Configuration.
1.`onDragComplete` On drag complete call back
```dart
  /// When horizontal drag is enough to cross [minThreshold] then it will be called.
  final VoidCallback? onDragComplete;

```

2.`onDragCancel` callback for drag cancel.

```dart
/// When horizontal drag is not enough to cross [minThreshold] and callback
/// canceled from user.
final VoidCallback? onDragCancel;
```


3.`alignment` For aligning child.

```dart
  /// This uses [Align] and [ColoredBox] internally to set Alignment of Widget
  /// so, the complete area of widget including whitespace can be available for
  /// hit-test.
  final Alignment alignment;
```

4.`dragDirection` It decides the drag direction of child.

```dart
  /// * If [DragDirection.RTL] then it can dragged from right side to left side.
  /// * If [DragDirection.LTR] then it can be dragged from left to to right.
  final DragDirection alignment;
```

5.`maxTranslation`  Value of width percentage of child,for max translation in direction.

```dart
 /// It defines bounds of translation in direction. If it is set to .3 then at
 /// max drag you will able to translate 30% of [child] size in any direction.
 final double maxTranslation;
```


6.`reverseDuration` Duration for reverse translation.

```dart
  /// If drag not completes or if it not crosses the [minThreshold] percentage
  /// of width then it play reverse animation with [reverseDuration] duration.
  final Duration reverseDuration;
```

7.`minThreshold`  A percentage of minThreshold for calling completeCallback.

```dart
  /// It helps to define boundary for calling [onDragComplete]. If it is set
  /// to .2 and the value of [maxTranslation] is set to .3 then if we leave 
  /// drag handle at grater than 15% of translation it will consider this action
  /// as threshold.
  final Duration reverseDuration;
```
