import 'package:eh/display.dart';

void main(List<String> arguments) async {
  Display.init();

  print(r"\x1b[?25h");

  Display.log('log1');
  await Future.delayed(Duration(milliseconds: 1000));
  Display.log('log2');
  await Future.delayed(Duration(milliseconds: 1000));
  Display.log('log3');
  await Future.delayed(Duration(milliseconds: 1000));
  Display.log('log4');
  await Future.delayed(Duration(milliseconds: 1000));

  // render(0.1);
  // await Future.delayed(Duration(milliseconds: 100));
  // render(0.2);
  // await Future.delayed(Duration(milliseconds: 100));
  // render(0.3);
  // await Future.delayed(Duration(milliseconds: 100));
  // render(0.4);
  // await Future.delayed(Duration(milliseconds: 100));
}
