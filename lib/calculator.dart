import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:calculator_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'change_theme.dart';

class Calculator extends StatefulWidget {
  const Calculator({
    super.key,
  });

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  final FlutterTts flutterTts = FlutterTts();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  var count = 0;
  double _confidence = 1.0;
  double num1 = 0;
  double num2 = 0;
  String history = "";
  String result = "";
  var operator = "";
  String text = "";
  String input = "";
  final List<String> buttonName = [
    "C",
    "+/-",
    "%",
    "DEL",
    "7",
    "8",
    "9",
    "÷",
    "4",
    "5",
    "6",
    "x",
    "1",
    "2",
    "3",
    "-",
    "0",
    ".",
    "=",
    "+",
  ];

  speak(String text) async {
    await flutterTts.setLanguage("tr-TR");
    await flutterTts.setPitch(1);
    await flutterTts.speak(result);
  }

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentWidth = MediaQuery.of(context).size.width;
    print("mic test : $text");

    if (text.contains("=") || text.contains("eşittir")) {
      try {
        text = text.replaceAll("eşittir", "=");
        text = text.substring(0, text.length - 1);
        text = text.replaceAll("x", "*");
        text = text.replaceAll(",", ".");
        text = text.replaceAll("artı", "+");
        Parser p = Parser();
        Expression exp = p.parse(text);
        ContextModel cm = ContextModel();
        double eval = exp.evaluate(EvaluationType.REAL, cm);
        int i = eval.toInt();
        result = i.toString();
        //result = '${exp.evaluate(EvaluationType.REAL, cm)}';

        speak(result);
      } catch (e) {
        result = "Hata";
        speak(result);
      }
    }
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        leading: AvatarGlow(
          animate: _isListening,
          glowColor: Colors.grey,
          endRadius: 75.0,
          duration: const Duration(milliseconds: 2000),
          repeatPauseDuration: const Duration(milliseconds: 100),
          repeat: true,
          child: SizedBox(
            width: 35,
            height: 35,
            child: FloatingActionButton(
              backgroundColor: Colors.grey[200],
              onPressed: _listen,
              child: Icon(
                _isListening == true ? Icons.mic : Icons.mic_none,
              ),
            ),
          ),
        ),
        actions: const [
          ChangeThemeButtonWidget(),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: currentWidth / 6),
                child: Row(
                  children: <Widget>[
                    // Text(text),
                    const Spacer(),
                    Text(
                      text.isEmpty ? history : text,
                      style: TextStyle(
                          color: Theme.of(context).iconTheme.color,
                          fontSize: 20,
                          fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: currentWidth / 6),
                child: Row(
                  children: [
                    const Spacer(),
                    Text(
                      result,
                      style: TextStyle(
                          color: Theme.of(context).iconTheme.color,
                          fontSize: result.length >= 10 ? 30 : 60,
                          fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: currentWidth / 12),
                child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 15,
                    ),
                    itemCount: buttonName.length,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemBuilder: ((context, index) {
                      bool greyCondition =
                          index == 0 || index == 1 || index == 2 || index == 3;
                      bool orangeCondition = index == 7 ||
                          index == 11 ||
                          index == 15 ||
                          index == 19;
                      bool operationCondition = buttonName[index] == "+" ||
                          buttonName[index] == "-" ||
                          buttonName[index] == "x" ||
                          buttonName[index] == "÷" ||
                          buttonName[index] == "%";

                      return ElevatedButton(
                        onPressed: () {
                          if (buttonName[index] == "C") {
                            text = "";
                            input = "";
                            history = "";
                            result = "";
                            num1 = 0;
                            num2 = 0;
                            count = 0;
                          } else if (buttonName[index] == "DEL") {
                            result = input.substring(0, input.length - 1);
                          } else if (buttonName[index] == "+/-") {
                            if (input[0] != "-") {
                              result = "-$result";
                            } else {
                              result = input.substring(1);
                            }
                          } else if (operationCondition) {
                            num1 = double.parse(input);
                            result = "";
                            operator = buttonName[index];
                            count = 0;
                          } else if (buttonName[index] == ".") {
                            result += ".";
                            count++;
                            if (count >= 2) {
                              setState(() {
                                result = result.substring(0, input.length);
                              });
                            }
                          } else if (buttonName[index] == "=") {
                            num2 = double.parse(input);
                            if (operator == "%") {
                              result = (num1 % num2).toString();
                              history = num1.toString() +
                                  operator.toString() +
                                  num2.toString();
                            }
                            if (operator == "+") {
                              result = (num1 + num2).toString();

                              history = num1.toString() +
                                  operator.toString() +
                                  num2.toString();
                              // if (result.contains(".") && result.length > 16) {
                              //   result = result.substring(0, 3);
                              // }
                            }
                            if (operator == "-") {
                              result = (num1 - num2).toString();
                              history = num1.toString() +
                                  operator.toString() +
                                  num2.toString();
                              // if (result.contains(".") && result.length > 16) {
                              //   result = result.substring(0, 3);
                              // }
                            }
                            if (operator == "÷") {
                              result = (num1 / num2).toString();
                              // result = result.substring(0, 6);
                              history = num1.toString() +
                                  operator.toString() +
                                  num2.toString();
                            }
                            if (operator == "x") {
                              result = (num1 * num2).toString();
                              history = num1.toString() +
                                  operator.toString() +
                                  num2.toString();
                            }
                          } else {
                            result =
                                num.parse(input + buttonName[index]).toString();
                          }
                          setState(() {
                            input = result;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            elevation: 7,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24)),
                            backgroundColor: greyCondition
                                ? Colors.grey[300]
                                : orangeCondition
                                    ? Colors.orange[700]
                                    : Colors.white),
                        child: Text(
                          buttonName[index],
                          style: TextStyle(
                            fontSize: 20,
                            color:
                                orangeCondition ? Colors.white : Colors.black,
                          ),
                        ),
                      );
                    })),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          print('onStatus: $val');
          if (val == "notListening") {
            print("a");
            setState(() {
              _isListening = false;
            });
          }
        },
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            input = val.recognizedWords;
            text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }
}
