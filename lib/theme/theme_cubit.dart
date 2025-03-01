import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

final textTheme = GoogleFonts.notoSansTextTheme().copyWith(
  titleSmall: GoogleFonts.notoSans(
    fontWeight: FontWeight.w300,
  ),
  titleMedium: GoogleFonts.notoSans(
    fontWeight: FontWeight.normal,
  ),
  titleLarge: GoogleFonts.notoSans(
    fontWeight: FontWeight.bold,
  ),
  bodyMedium: GoogleFonts.notoSans(
    fontWeight: FontWeight.w500,
    fontSize: 15,
  ),
);
/*
Fonts: https://fontjoy.com/

Merienda One
Neuton
Montserrat Alternates

*/
/*
https://colorscheme.enoiu.com/
https://colorffy.com/color-scheme-generator
lightTheme
component           schemeName	        hex			  argb
scaffoldBackground	scaffold	          6e7579 		rgb(110, 117, 121)
titlebar 	          outline		          303334		rgb(48, 51, 52)
titlebarText 	      outlineVariant		  d3d6d7		argb(255,211,214,21)

darkTheme
component           schemeName	        hex			  argb
scaffoldBackground	scaffold	          3f4244 		rgb(110, 117, 121)
titlebar: 	        outline		          151616		(rgb(21, 22, 22)
titlebarText 	      outlineVariant		  e9eaeb		argb(255,233,234,23)
*/

ThemeData lightTheme = ThemeData.light().copyWith(
  scaffoldBackgroundColor: const Color(0xFFa540d0),
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    outline: const Color.fromARGB(255, 199, 9, 176),
    outlineVariant: const Color(0xFFd3d6d7),
    background: Colors.grey.shade800,
    primary: const Color(0xFFD88CF1),
    onPrimary: const Color(0xFF371227),
    secondary: const Color(0xffc683e1),
    onSecondary: const Color(0xff340347),
    primaryContainer: const Color(0xff4609c7),
    inversePrimary: const Color(0xff8758d9),
    surface: Colors.grey.shade400,
    tertiary: const Color(0xFFBF27AD),
    onTertiary: const Color(0xFFF5D3F2),
    onTertiaryContainer: Colors.black54,
    surfaceVariant: const Color(0xFF05769C),
    secondaryContainer: const Color(0xFF76B1C5),
  ),
  textTheme: textTheme,
  datePickerTheme: const DatePickerThemeData(
    headerBackgroundColor: Color(0xFFBF27AD),
    headerForegroundColor: Colors.white70,
    confirmButtonStyle: ButtonStyle(
      foregroundColor: MaterialStatePropertyAll(Color(0xff340347)),
      textStyle: MaterialStatePropertyAll(
        TextStyle(fontWeight: FontWeight.w500),
      ),
    ),
    cancelButtonStyle: ButtonStyle(
      foregroundColor: MaterialStatePropertyAll(Color(0xff340347)),
      textStyle: MaterialStatePropertyAll(
        TextStyle(fontWeight: FontWeight.w500),
      ),
    ),
    backgroundColor: Color(0xffc683e1),
  ),
);

ThemeData darkTheme = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: const Color(0xFF2c1237),
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    outline: const Color(0xFF52183c),
    outlineVariant: const Color(0xFFe9eaeb),
    background: Colors.grey.shade900,
    primary: const Color(0xff67168a),
    onPrimary: const Color(0xffe4c1f0),
    secondary: const Color(0xff3f1551),
    onSecondary: Colors.white60,
    primaryContainer: const Color(0xffb809c7),
    inversePrimary: const Color(0xff66196d),
    surface: Colors.grey.shade700,
    tertiary: const Color(0xFF8b1963),
    onTertiary: const Color(0xFFF5D3F2),
    onTertiaryContainer: Colors.white60,
    surfaceVariant: const Color(0xDC3A122A),
    secondaryContainer: const Color(0xDC531E3D),
    // surfaceVariant: const Color(0xCF7D370F),
    // secondaryContainer: const Color(0xEE563522),
  ),
  textTheme: textTheme,
  datePickerTheme: const DatePickerThemeData(
    headerBackgroundColor: Color(0xFF8b1963),
    headerForegroundColor: Colors.white70,
    confirmButtonStyle: ButtonStyle(
      foregroundColor: MaterialStatePropertyAll(Colors.white70),
      textStyle: MaterialStatePropertyAll(
        TextStyle(fontWeight: FontWeight.w500),
      ),
    ),
    cancelButtonStyle: ButtonStyle(
      foregroundColor: MaterialStatePropertyAll(Colors.white70),
      textStyle: MaterialStatePropertyAll(
        TextStyle(fontWeight: FontWeight.w500),
      ),
    ),
    backgroundColor: Color(0xFF3B174B),
  ),
);

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light);

  setTheme(String themeMode) {
    emit(themeMode == 'ThemeMode.light' ? ThemeMode.light : ThemeMode.dark);
  }

  toggleTheme() {
    emit(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }
}
