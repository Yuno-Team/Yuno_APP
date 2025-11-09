import 'package:flutter/material.dart';

class LoadingSkeleton extends StatefulWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const LoadingSkeleton({
    Key? key,
    required this.height,
    this.width,
    this.borderRadius = 6.0,
  }) : super(key: key);

  @override
  _LoadingSkeletonState createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            color: Color(0xFF252931).withOpacity(
              0.7 + (0.3 * _animation.value),
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}

class PolicyCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: LoadingSkeleton(
        height: 56,
        borderRadius: 6,
      ),
    );
  }
}



