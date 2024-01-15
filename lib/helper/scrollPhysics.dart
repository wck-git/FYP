import 'package:flutter/material.dart';

class PositionRetainedScrollPhysics extends ScrollPhysics {
  final bool shouldRetain;

  const PositionRetainedScrollPhysics({super.parent, this.shouldRetain = true});

  @override
  PositionRetainedScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return PositionRetainedScrollPhysics(
      parent: buildParent(ancestor),
      shouldRetain: shouldRetain,
    );
  }

  @override
  double adjustPositionForNewDimensions({
    required ScrollMetrics oldPosition,
    required ScrollMetrics newPosition,
    required bool isScrolling,
    required double velocity,
  }) {
    final position = super.adjustPositionForNewDimensions(
      oldPosition: oldPosition,
      newPosition: newPosition,
      isScrolling: isScrolling,
      velocity: velocity,
    );

    final diff = newPosition.maxScrollExtent - oldPosition.maxScrollExtent;

    // addition
    if (oldPosition.pixels > oldPosition.minScrollExtent &&
        diff > 0 &&
        shouldRetain &&
        !isScrolling) {
      return oldPosition.pixels + 313;
    }
    // deletion
    else if (oldPosition.pixels > oldPosition.minScrollExtent &&
        diff < 0 &&
        shouldRetain &&
        !isScrolling) {
      return oldPosition.pixels;
      // return oldPosition.pixels - 313;
    } else {
      return position;
    }
  }
}

// print('Diff:" ${diff}');
// print('Old PX ${oldPosition.pixels}');
// print('Old max ${oldPosition.maxScrollExtent}');
// print('New PX ${newPosition.pixels}');
// print('New max ${newPosition.maxScrollExtent}');
// print("==============================");
