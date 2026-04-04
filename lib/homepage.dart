import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: Calculator(),
  ));
}

class Calculator extends StatefulWidget {
  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String output = "0";       // texte affiché
  String _input = "";        // texte temporaire pour calcul
  double num1 = 0;
  double num2 = 0;
  String operator = "";

  void buttonPressed(String buttonText) {
    if (buttonText == "C") {
      _input = "";
      num1 = 0;
      num2 = 0;
      operator = "";
      output = "0";
    } else if (buttonText == "+" || buttonText == "-" || buttonText == "*" || buttonText == "/") {
      num1 = double.parse(_input);
      operator = buttonText;
      _input = "";
    } else if (buttonText == "=") {
      num2 = double.parse(_input);
      if (operator == "+") {
        output = (num1 + num2).toString();
      } else if (operator == "-") {
        output = (num1 - num2).toString();
      } else if (operator == "*") {
        output = (num1 * num2).toString();
      } else if (operator == "/") {
        output = (num1 / num2).toString();
      }
      _input = output;
      operator = "";
    } else {
      _input += buttonText;
      output = _input;
    }

    setState(() {});
  }

  Widget buildButton(String buttonText) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () => buttonPressed(buttonText),
        child: Text(
          buttonText,
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Calculatrice Flutter")),
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: EdgeInsets.all(24),
              child: Text(output, style: TextStyle(fontSize: 48)),
            ),
          ),
          Row(
            children: [buildButton("7"), buildButton("8"), buildButton("9"), buildButton("/")],
          ),
          Row(
            children: [buildButton("4"), buildButton("5"), buildButton("6"), buildButton("*")],
          ),
          Row(
            children: [buildButton("1"), buildButton("2"), buildButton("3"), buildButton("-")],
          ),
          Row(
            children: [buildButton("0"), buildButton("C"), buildButton("="), buildButton("+")],
          ),
        ],
      ),
    );
  }
}