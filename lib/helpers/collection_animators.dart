import 'package:flutter/material.dart';

class CollectionScaleTransition extends StatefulWidget {
  /// Collection of widgets on which slide animation is applied.
  ///
  /// Preferably, [Text], [Icon] or [Image] should be used.
  final List<Widget> children;

  /// End scale of each child.
  final double end;

  /// Start scale of each child.
  final double begin = 1.0;

  final AnimationController controller;

  /// Creates transiton widget.
  ///
  /// [children] is requied and must not be null.
  /// [end] property has default value of 2.0.
  CollectionScaleTransition({
    @required this.children,
    @required this.controller,
    this.end = 2.0,
  }) : assert(children != null);

  @override
  _CollectionScaleTransitionState createState() =>
      new _CollectionScaleTransitionState();
}

class _CollectionScaleTransitionState extends State<CollectionScaleTransition> {
  List<_WidgetAnimations<double>> _widgets;

  @override
  void initState() {
    super.initState();

    _widgets = _WidgetAnimations.createList<double>(
      widgets: widget.children,
      controller: widget.controller,
      forwardCurve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
      begin: widget.begin,
      end: widget.end,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final end = widget.end;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _widgets.map(
        (widgetAnimation) {
          return AnimatedBuilder(
            animation: widget.controller,
            builder: (context, _) {
              return Transform.scale(
                scale: widgetAnimation.forward.value >= end
                    ? widgetAnimation.reverse.value
                    : widgetAnimation.forward.value,
                child: widgetAnimation.widget,
              );
            },
          );
        },
      ).toList(),
    );
  }
}

class _WidgetAnimations<T> {
  final Widget widget;
  final Animation<T> forward;
  final Animation<T> reverse;

  _WidgetAnimations({this.widget, this.forward, this.reverse});

  static List<_WidgetAnimations<S>> createList<S>({
    @required List<Widget> widgets,
    @required AnimationController controller,
    Cubic forwardCurve = Curves.ease,
    Cubic reverseCurve = Curves.ease,
    S begin,
    S end,
  }) {
    final animations = <_WidgetAnimations<S>>[];

    var start = 0.0;
    final duration = 1.0 / (widgets.length * 2);
    widgets.forEach((childWidget) {
      final animation = Tween<S>(
        begin: begin,
        end: end,
      ).animate(
        CurvedAnimation(
          curve: Interval(start, start + duration, curve: Curves.ease),
          parent: controller,
        ),
      );

      final revAnimation = Tween<S>(
        begin: end,
        end: begin,
      ).animate(
        CurvedAnimation(
          curve: Interval(start + duration, start + duration * 2,
              curve: Curves.ease),
          parent: controller,
        ),
      );

      animations.add(_WidgetAnimations(
        widget: childWidget,
        forward: animation,
        reverse: revAnimation,
      ));

      start += duration;
    });

    return animations;
  }
}
