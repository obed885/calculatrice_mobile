import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:math' as math;

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  title: 'Calculatrice Scientifique',
  theme: ThemeData.dark().copyWith(
    primaryColor: Colors.black,
    scaffoldBackgroundColor: Colors.black,
  ),
  home: ScientificCalculator(),
));

class ScientificCalculator extends StatefulWidget {
  @override
  _ScientificCalculatorState createState() => _ScientificCalculatorState();
}

class _ScientificCalculatorState extends State<ScientificCalculator> {
  // Types de variables
  String input = "";
  String output = "0";
  String memory = "0";
  List<String> history = [];
  bool isShifted = false;
  bool isRadians = true;
  String lastResult = "0";
  bool showScientific = true;

  // Constantes
  final double pi = math.pi;
  final double e = math.e;

  @override
  void initState() {
    super.initState();
    // Déterminer si on affiche les fonctions scientifiques basé sur la taille de l'écran
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        showScientific = MediaQuery.of(context).size.width > 600;
      });
    });
  }

  void buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "C") {
        input = "";
        output = "0";
      } else if (buttonText == "CE") {
        if (input.isNotEmpty) {
          input = input.substring(0, input.length - 1);
          if (input.isEmpty) output = "0";
        }
      } else if (buttonText == "AC") {
        input = "";
        output = "0";
        memory = "0";
      } else if (buttonText == "DEL") {
        if (input.isNotEmpty) input = input.substring(0, input.length - 1);
        if (input.isEmpty) output = "0";
      } else if (buttonText == "=") {
        calculateResult();
      } else if (buttonText == "M+") {
        memory = (double.parse(memory) + double.parse(output)).toString();
      } else if (buttonText == "M-") {
        memory = (double.parse(memory) - double.parse(output)).toString();
      } else if (buttonText == "MR") {
        input += memory;
      } else if (buttonText == "MC") {
        memory = "0";
      } else if (buttonText == "x²") {
        input += "^2";
      } else if (buttonText == "x³") {
        input += "^3";
      } else if (buttonText == "xʸ") {
        input += "^";
      } else if (buttonText == "eˣ") {
        input += "e^(";
      } else if (buttonText == "10ˣ") {
        input += "10^(";
      } else if (buttonText == "√") {
        input += "sqrt(";
      } else if (buttonText == "∛") {
        input += "cbrt(";
      } else if (buttonText == "1/x") {
        input += "1/(";
      } else if (buttonText == "|x|") {
        input += "abs(";
      } else if (buttonText == "⌊x⌋") {
        input += "floor(";
      } else if (buttonText == "⌈x⌉") {
        input += "ceil(";
      } else if (buttonText == "SHIFT") {
        isShifted = !isShifted;
      } else if (buttonText == "RAD") {
        isRadians = !isRadians;
      } else if (buttonText == "π") {
        input += pi.toString();
      } else if (buttonText == "e") {
        input += e.toString();
      } else if (buttonText == "Ans") {
        input += lastResult;
      } else if (buttonText == "!") {
        input += "!";
      } else if (buttonText == "mod") {
        input += "%";
      } else if (buttonText == "toggleScientific") {
        setState(() {
          showScientific = !showScientific;
        });
      } else {
        input += buttonText;
      }
    });
  }

  void calculateResult() {
    try {
      String expression = input;

      expression = expression
          .replaceAll("×", "*")
          .replaceAll("÷", "/")
          .replaceAll("^", "^");

      if (isShifted) {
        expression = expression
            .replaceAll("sin(", "asin(")
            .replaceAll("cos(", "acos(")
            .replaceAll("tan(", "atan(");
      }

      expression = expression
          .replaceAll("sinh(", "sinh(")
          .replaceAll("cosh(", "cosh(")
          .replaceAll("tanh(", "tanh(");

      if (isShifted) {
        expression = expression
            .replaceAll("asinh(", "asinh(")
            .replaceAll("acosh(", "acosh(")
            .replaceAll("atanh(", "atanh(");
      }

      expression = expression
          .replaceAll("ln(", "log(")
          .replaceAll("log(", "log10(")
          .replaceAll("lb(", "log2(");

      expression = expression
          .replaceAll("sqrt(", "sqrt(")
          .replaceAll("cbrt(", "cbrt(");

      expression = expression
          .replaceAll("abs(", "abs(")
          .replaceAll("floor(", "floor(")
          .replaceAll("ceil(", "ceil(");

      if (expression.contains("!")) {
        expression = expression.replaceAll("!", "");
        Parser p = Parser();
        Expression exp = p.parse(expression);
        ContextModel cm = ContextModel();
        double eval = exp.evaluate(EvaluationType.REAL, cm);
        eval = factorial(eval.toInt());
        output = formatResult(eval);
        history.add("$input = $output");
        lastResult = output;
        return;
      }

      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      output = formatResult(eval);
      history.add("$input = $output");
      lastResult = output;
    } catch (e) {
      output = "Erreur";
    }
  }

  double factorial(int n) {
    if (n < 0) return double.nan;
    if (n == 0 || n == 1) return 1;
    double result = 1;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }

  String formatResult(double value) {
    if (value.isNaN) return "Erreur";
    if (value.isInfinite) return "Infini";

    if (value == value.toInt()) {
      return value.toInt().toString();
    }

    String result = value.toStringAsFixed(10);
    result = result.replaceAll(RegExp(r'0+$'), '');
    result = result.replaceAll(RegExp(r'\.$'), '');

    if (result.length > 20) {
      return value.toStringAsExponential(8);
    }

    return result;
  }

  Widget buildButton(String text,
      {Color? color,
        bool isOperator = false,
        bool isNumber = false,
        bool isFunction = false,
        bool isScientific = false}) {

    final screenWidth = MediaQuery.of(context).size.width;
    final buttonSize = screenWidth < 400 ? 50.0 : 60.0;
    final fontSize = screenWidth < 400 ? 16.0 : (isOperator ? 24.0 : 20.0);

    Color buttonColor;
    Color textColor = Colors.white;

    if (isOperator) {
      buttonColor = Color(0xFFFF9F0A);
    } else if (isNumber) {
      buttonColor = Color(0xFF333333);
    } else if (isFunction) {
      buttonColor = Color(0xFFA5A5A5);
      textColor = Colors.black;
    } else if (isScientific) {
      buttonColor = Color(0xFF2C2C2E);
    } else {
      buttonColor = color ?? Color(0xFF505050);
    }

    if (text == "SHIFT" && isShifted) {
      buttonColor = Color(0xFFFF9F0A);
      textColor = Colors.white;
    }

    if (text == "RAD" && !isRadians) {
      buttonColor = Color(0xFFFF9F0A);
      textColor = Colors.white;
    }

    return Expanded(
      child: Container(
        margin: EdgeInsets.all(screenWidth < 400 ? 3 : 4),
        child: ElevatedButton(
          onPressed: () => buttonPressed(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: textColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
            padding: EdgeInsets.symmetric(vertical: screenWidth < 400 ? 12 : 16),
            minimumSize: Size(buttonSize, buttonSize),
            elevation: 0,
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget buildHistory() {
    if (history.isEmpty) {
      return Center(
        child: Text("Aucun historique", style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      itemCount: history.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                history[history.length - 1 - index].split("=")[0],
                style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                "= ${history[history.length - 1 - index].split("=")[1]}",
                style: TextStyle(fontSize: 20, color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
              Divider(color: Color(0xFF3A3A3C)),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Calculatrice Scientifique",
          style: TextStyle(color: Colors.white, fontSize: isTablet ? 24 : 20),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (!isTablet)
            IconButton(
              icon: Icon(showScientific ? Icons.science : Icons.calculate, color: Colors.white),
              onPressed: () => buttonPressed("toggleScientific"),
              tooltip: showScientific ? "Mode simple" : "Mode scientifique",
            ),
          IconButton(
            icon: Icon(Icons.history, color: Colors.white),
            onPressed: () => showModalBottomSheet(
              context: context,
              backgroundColor: Color(0xFF1C1C1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => Container(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        "Historique des calculs",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                    Expanded(child: buildHistory()),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          history.clear();
                        });
                        Navigator.pop(context);
                      },
                      child: Text("Effacer l'historique", style: TextStyle(color: Colors.red)),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              // Affichage
              Container(
                padding: EdgeInsets.all(screenWidth < 400 ? 16 : 20),
                color: Colors.black,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        input.isEmpty ? " " : input,
                        style: TextStyle(fontSize: screenWidth < 400 ? 24 : 32, color: Colors.grey[400]),
                      ),
                    ),
                    SizedBox(height: screenWidth < 400 ? 5 : 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        output,
                        style: TextStyle(
                            fontSize: screenWidth < 400 ? 40 : (isTablet ? 64 : 56),
                            fontWeight: FontWeight.w300,
                            color: Colors.white
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("MEM: $memory", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        Row(
                          children: [
                            if (isShifted)
                              Container(
                                margin: EdgeInsets.only(right: 10),
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Color(0xFFFF9F0A),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text("SHIFT", style: TextStyle(color: Colors.white, fontSize: 10)),
                              ),
                            Text(isRadians ? "RAD" : "DEG", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Boutons
              Expanded(
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Container(
                    padding: EdgeInsets.all(screenWidth < 400 ? 4 : 8),
                    child: Column(
                      children: [
                        // Version complète pour tablette ou mode scientifique
                        if (isTablet || showScientific) ...[
                          _buildScientificButtons(screenWidth, isTablet),
                        ],
                        // Version simple pour petits écrans
                        if (!isTablet && !showScientific) ...[
                          _buildBasicButtons(screenWidth),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildScientificButtons(double screenWidth, bool isTablet) {
    final buttonSize = screenWidth < 400 ? 50.0 : 60.0;

    return Column(
      children: [
        // Ligne 1: SHIFT, RAD, constantes
        ResponsiveRow(
          children: [
            buildButton("SHIFT", isFunction: true),
            buildButton("RAD", isFunction: true),
            buildButton("π", isScientific: true),
            buildButton("e", isScientific: true),
            buildButton("Ans", isScientific: true),
          ],
        ),
        // Ligne 2: Trigonométriques
        ResponsiveRow(
          children: [
            buildButton("sin(", isScientific: true),
            buildButton("cos(", isScientific: true),
            buildButton("tan(", isScientific: true),
            if (isTablet) buildButton("sinh(", isScientific: true),
            if (isTablet) buildButton("cosh(", isScientific: true),
          ],
        ),
        // Ligne 3: Logarithmes
        ResponsiveRow(
          children: [
            buildButton("ln(", isScientific: true),
            buildButton("log(", isScientific: true),
            buildButton("lb(", isScientific: true),
            buildButton("√", isScientific: true),
            buildButton("∛", isScientific: true),
          ],
        ),
        // Ligne 4: Puissances
        ResponsiveRow(
          children: [
            buildButton("x²", isScientific: true),
            buildButton("x³", isScientific: true),
            buildButton("xʸ", isScientific: true),
            buildButton("eˣ", isScientific: true),
            buildButton("10ˣ", isScientific: true),
          ],
        ),
        // Ligne 5: Autres fonctions
        ResponsiveRow(
          children: [
            buildButton("1/x", isScientific: true),
            buildButton("|x|", isScientific: true),
            buildButton("⌊x⌋", isScientific: true),
            buildButton("⌈x⌉", isScientific: true),
            buildButton("!", isScientific: true),
          ],
        ),
        // Ligne 6: Parenthèses et opérateurs
        ResponsiveRow(
          children: [
            buildButton("(", isFunction: true),
            buildButton(")", isFunction: true),
            buildButton("%", isFunction: true),
            buildButton("mod", isFunction: true),
            buildButton("÷", isOperator: true),
          ],
        ),
        // Ligne 7: Chiffres 7-9
        ResponsiveRow(
          children: [
            buildButton("7", isNumber: true),
            buildButton("8", isNumber: true),
            buildButton("9", isNumber: true),
            buildButton("MC", isFunction: true),
            buildButton("×", isOperator: true),
          ],
        ),
        // Ligne 8: Chiffres 4-6
        ResponsiveRow(
          children: [
            buildButton("4", isNumber: true),
            buildButton("5", isNumber: true),
            buildButton("6", isNumber: true),
            buildButton("MR", isFunction: true),
            buildButton("-", isOperator: true),
          ],
        ),
        // Ligne 9: Chiffres 1-3
        ResponsiveRow(
          children: [
            buildButton("1", isNumber: true),
            buildButton("2", isNumber: true),
            buildButton("3", isNumber: true),
            buildButton("M-", isFunction: true),
            buildButton("+", isOperator: true),
          ],
        ),
        // Ligne 10: Chiffre 0, point, CE, M+
        ResponsiveRow(
          children: [
            buildButton("0", isNumber: true),
            buildButton(".", isNumber: true),
            buildButton("CE", isFunction: true),
            buildButton("M+", isFunction: true),
            buildButton("=", isOperator: true),
          ],
        ),
        // Ligne 11: C, AC, DEL
        ResponsiveRow(
          children: [
            buildButton("C", isFunction: true),
            buildButton("AC", isFunction: true),
            buildButton("DEL", isFunction: true),
          ],
        ),
      ],
    );
  }

  Widget _buildBasicButtons(double screenWidth) {
    return Column(
      children: [
        // Ligne 1: Parenthèses et opérateurs
        ResponsiveRow(
          children: [
            buildButton("(", isFunction: true),
            buildButton(")", isFunction: true),
            buildButton("%", isFunction: true),
            buildButton("÷", isOperator: true),
          ],
        ),
        // Ligne 2: Chiffres 7-9
        ResponsiveRow(
          children: [
            buildButton("7", isNumber: true),
            buildButton("8", isNumber: true),
            buildButton("9", isNumber: true),
            buildButton("×", isOperator: true),
          ],
        ),
        // Ligne 3: Chiffres 4-6
        ResponsiveRow(
          children: [
            buildButton("4", isNumber: true),
            buildButton("5", isNumber: true),
            buildButton("6", isNumber: true),
            buildButton("-", isOperator: true),
          ],
        ),
        // Ligne 4: Chiffres 1-3
        ResponsiveRow(
          children: [
            buildButton("1", isNumber: true),
            buildButton("2", isNumber: true),
            buildButton("3", isNumber: true),
            buildButton("+", isOperator: true),
          ],
        ),
        // Ligne 5: Chiffre 0, point, C, =
        ResponsiveRow(
          children: [
            buildButton("0", isNumber: true),
            buildButton(".", isNumber: true),
            buildButton("C", isFunction: true),
            buildButton("=", isOperator: true),
          ],
        ),
        // Ligne 6: DEL
        ResponsiveRow(
          children: [
            buildButton("DEL", isFunction: true),
          ],
        ),
      ],
    );
  }
}

// Widget personnalisé pour les lignes responsives
class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;

  const ResponsiveRow({Key? key, required this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      children: children.map((child) {
        if (screenWidth < 360 && children.length > 4) {
          return Flexible(child: child);
        }
        return child;
      }).toList(),
    );
  }
}