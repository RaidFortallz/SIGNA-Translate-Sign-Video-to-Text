import 'package:flutter/material.dart';
import 'package:signa_video_to_text/features/config/themes/colors_theme.dart';

class TextCustom extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final TextAlign textAlign;
  final double letterSpacing;
  
  const TextCustom(
    this.text, {
    super.key,
    this.fontSize = 14,
    this.fontWeight = FontWeight.normal,
    this.color = WarnaApp.wrTextBlack,
    this.textAlign = TextAlign.left,
    this.letterSpacing = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
      ),
    );
  }
}
