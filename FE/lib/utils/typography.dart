import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class YunoTypography {
  // Heading Styles - Noto Sans 사용
  static TextStyle get h1 => GoogleFonts.notoSans(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );
  
  static TextStyle get h2 => GoogleFonts.notoSans(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );
  
  static TextStyle get h3 => GoogleFonts.notoSans(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  
  // Body Text Styles  
  static TextStyle get p1 => GoogleFonts.notoSans(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );
  
  static TextStyle get p2 => GoogleFonts.notoSans(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );
  
  static TextStyle get p3 => GoogleFonts.notoSans(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.3,
  );

  // Small Text Styles
  static TextStyle get t1 => GoogleFonts.notoSans(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    height: 1.2,
  );
  
  static TextStyle get t2 => GoogleFonts.notoSans(
    fontSize: 10,
    fontWeight: FontWeight.normal,
    height: 1.1,
  );

  // Color variations
  static TextStyle h1White = h1.copyWith(color: Colors.white);
  static TextStyle h1Black = h1.copyWith(color: Colors.black);
  static TextStyle h2White = h2.copyWith(color: Colors.white);
  static TextStyle h2Black = h2.copyWith(color: Colors.black);
  static TextStyle h3White = h3.copyWith(color: Colors.white);
  static TextStyle h3Black = h3.copyWith(color: Colors.black);
  
  static TextStyle p1White = p1.copyWith(color: Colors.white);
  static TextStyle p1Black = p1.copyWith(color: Colors.black);
  static TextStyle p1Grey = p1.copyWith(color: Colors.grey[600]);
  static TextStyle p1Grey70 = p1.copyWith(color: Colors.white70);
  
  static TextStyle p2White = p2.copyWith(color: Colors.white);
  static TextStyle p2Black = p2.copyWith(color: Colors.black);
  static TextStyle p2Grey = p2.copyWith(color: Colors.grey[600]);
  static TextStyle p2Grey70 = p2.copyWith(color: Colors.white70);
  
  static TextStyle p3White = p3.copyWith(color: Colors.white);
  static TextStyle p3Black = p3.copyWith(color: Colors.black);
  static TextStyle p3Grey = p3.copyWith(color: Colors.grey[600]);
}