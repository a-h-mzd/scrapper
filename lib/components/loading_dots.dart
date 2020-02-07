import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:scrapper/helpers/collection_animators.dart';

class LoadingDots extends StatefulWidget {
  @override
  _LoadingDotsState createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots> implements TickerProvider {
  AnimationController _controller;
  Animatable<Color> _color;
  List<Widget> _widgets;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat();

    final double size = 16;

    _color = TweenSequence<Color>([
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Colors.black,
          end: Colors.blue,
        ),
      ),
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Colors.blue,
          end: Colors.black,
        ),
      ),
    ]);

    _widgets = <Widget>[
      AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Icon(
              Icons.lens,
              size: size,
              color: _color.transform(Interval(0, 1, curve: Curves.ease)
                  .transform(_controller.value > 2 / 3
                      ? 0
                      : _controller.value * 3 / 2)),
            );
          }),
      AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Icon(
              Icons.lens,
              size: size,
              color: _color.transform(Interval(0, 1, curve: Curves.ease)
                  .transform(_controller.value < 1 / 6
                      ? 0
                      : _controller.value > 5 / 6
                          ? 0
                          : (_controller.value - 1 / 6) * 3 / 2)),
            );
          }),
      AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Icon(
              Icons.lens,
              size: size,
              color: _color.transform(Interval(0, 1, curve: Curves.ease)
                  .transform(_controller.value < 1 / 3
                      ? 0
                      : (_controller.value - 1 / 3) * 3 / 2)),
            );
          }),
    ]
        .map(
          (widget) => Padding(
            padding: const EdgeInsets.all(24.0),
            child: widget,
          ),
        )
        .toList(growable: false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CollectionScaleTransition(
      controller: _controller,
      children: _widgets,
    );
  }

  @override
  Ticker createTicker(onTick) {
    return Ticker(onTick);
  }
}
