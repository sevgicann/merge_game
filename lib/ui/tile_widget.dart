import 'package:flutter/material.dart';

class AnimatedTile extends StatefulWidget {

  final int value;

  const AnimatedTile({
    super.key,
    required this.value,
  });

  @override
  State<AnimatedTile> createState() => _AnimatedTileState();
}

class _AnimatedTileState extends State<AnimatedTile>
    with SingleTickerProviderStateMixin {

  late AnimationController controller;
  late Animation<double> scale;

  @override
  void initState() {

    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );

    scale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ),
    );

    controller.forward();

  }

  @override
  void didUpdateWidget(covariant AnimatedTile oldWidget) {

    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      controller.forward(from: 0);
    }

  }

  @override
  Widget build(BuildContext context) {

    return ScaleTransition(
      scale: scale,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _tileColor(widget.value),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          widget.value == 0 ? "" : widget.value.toString(),
          style: TextStyle(
            fontSize: widget.value >= 1024 ? 24 : 28,
            fontWeight: FontWeight.bold,
            color: widget.value <= 4 ? Colors.black87 : Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Color _tileColor(int v) {

    switch (v) {

      case 0: return Colors.grey.shade300;
      case 2: return const Color(0xffeee4da);
      case 4: return const Color(0xffede0c8);
      case 8: return const Color(0xfff2b179);
      case 16: return const Color(0xfff59563);
      case 32: return const Color(0xfff67c5f);
      case 64: return const Color(0xfff65e3b);
      case 128: return const Color(0xffedcf72);
      case 256: return const Color(0xffedcc61);
      case 512: return const Color(0xffedc850);
      case 1024: return const Color(0xffedc53f);
      case 2048: return const Color(0xffedc22e);

    }

    return Colors.black;
  }

}