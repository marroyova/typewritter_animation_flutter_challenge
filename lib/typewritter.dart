import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const kBaseColor = Colors.black;
const kFontSizeTitle = 22.0;

class TypewriterAnimation extends StatefulWidget {
  final String text;

  const TypewriterAnimation({super.key, required this.text});

  @override
  TypewriterAnimationState createState() => TypewriterAnimationState();
}

class TypewriterAnimationState extends State<TypewriterAnimation>
    with TickerProviderStateMixin {
  late AnimationController _textController;
  late Animation<int> _textAnimation;
  late AnimationController _cursorController;
  late Animation<double> _cursorAnimation;
  late AnimationController _cursorBlinkController;
  late Animation<double> _cursorBlinkAnimation;

  @override
  void initState() {
    super.initState();
    _textController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    _textAnimation =
        IntTween(begin: 0, end: widget.text.length).animate(_textController);

    _textController.forward();
    _textController.addListener(() {
      setState(() {});
    });

    _textController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _waitAndReverse();
      } else if (status == AnimationStatus.dismissed) {
        _textController.forward();
      }
    });

    _cursorController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _cursorAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_cursorController)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _cursorController.reverse();
            } else if (status == AnimationStatus.dismissed) {
              _cursorController.forward();
            }
          });

    _cursorBlinkController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _cursorBlinkAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_cursorBlinkController)
          ..addListener(() {
            setState(() {});
          });

    _cursorController.forward();
    _cursorBlinkController.repeat();
  }

  void _waitAndReverse() {
    _cursorController.reset();
    _cursorBlinkController.reset();
    _cursorController.forward();
    _cursorBlinkController.repeat();
    Future.delayed(const Duration(seconds: 1), () {
      _textController.reverse();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _cursorController.dispose();
    _cursorBlinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String animatedText = widget.text.substring(0, _textAnimation.value);
    final bool showCursor =
        _cursorAnimation.value >= 0.5 && _cursorBlinkAnimation.value >= 0.5;
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Row(
          children: [
            Flexible(
              child: Text(
                showCursor ? "${animatedText}_" : animatedText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: kBaseColor,
                  fontSize: kFontSizeTitle + size.width * .010,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
