import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui' as ui;

class FadePageRoute<T> extends PageRoute<T>{
  FadePageRoute({
    @required this.builder,
    RouteSettings settings,
    this.maintainState = true,
    bool fullScreenDialog = false
  }) : assert(builder != null),
       assert(maintainState != null),
       assert(fullScreenDialog != null),
       assert(opaque),
       super(settings: settings, fullscreenDialog: fullScreenDialog);

  final WidgetBuilder builder;

  @override
  final bool maintainState; 

  @override
  Duration get transitionDuration => const Duration(milliseconds: 400);

  @override
  Color get barrierColor => null;

  @override
  String get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation){
    final Widget result = builder(context);
    assert((){
      if (result == null) {
        throw FlutterError(
            'The builder for route "${settings.name}" returned null.\n'
            'Route builders must never return null.');
      }
      return true;
    }());
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: result,
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondAnimation, Widget child){
    // final Widget result = builder(context);
    return _FadeInPageTransition(routeAnimation: animation, child: child);
  }
}

class _FadeInPageTransition extends StatelessWidget {
  _FadeInPageTransition({
    Key key,
    @required Animation<double> routeAnimation,
    @required this.child,
  })  : _positionAnimation = routeAnimation.drive(_bottomUpTween.chain(_fastOutSlowInTween)),
        _opacityAnimation = routeAnimation.drive(_easeInTween),
        super(key: key);
  
  static final Animatable<double> _easeInTween =
      CurveTween(curve: Curves.easeIn);
  
  static final Tween<Offset> _bottomUpTween = Tween<Offset>(
    begin: const Offset(0.0, 0.25),
    end: Offset.zero
  );

  static final Animatable<double> _fastOutSlowInTween = CurveTween(curve: Curves.fastOutSlowIn);

  final Animation<Offset> _positionAnimation;
  final Animation<double> _opacityAnimation;
  final Widget child;
  
  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _positionAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Material(
          color: Colors.white.withOpacity(0.1),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(
              sigmaX: 20.0,
              sigmaY: 20.0,
            ),
            child: child,
          ),
        )
      ),
    );
  }
}