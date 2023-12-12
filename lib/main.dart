import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;

import 'package:project/components/glass_effect.dart';

void main() {
  runApp(const MyApp());
}

class CurrencyInfo {
  final String name;
  final double price;

  CurrencyInfo(this.name, this.price);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Project'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<CurrencyInfo> currencies = [];

  int choosenFirstCurrency = 0;
  int choosenSecondCurrency = 1;

  final String apiKey = "7957dc5d0431b0026cafe72710400dca";

  final TextEditingController _first = TextEditingController();
  final TextEditingController _second = TextEditingController();

  double _currentSliderValue = 0;
  double _currentSliderSecondValue = 0;

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Krótka informacja'),
          content: const Text(
            'Projekt jest napisany w języku programowania Dart\n'
            'przy użyciu frameworka Flutter\n'
            '\n'
            'Pobieram dane o kursach wymiany z darmowego API\n'
            'Exchange Rates API\n',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Zamknąć'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchCurrencyData();
  }

  Future<void> fetchCurrencyData() async {
    try {
      final url = Uri.parse(
          'http://api.exchangeratesapi.io/v1/latest?access_key=$apiKey');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final Map<String, dynamic> rates = data['rates'];

        rates.forEach((key, value) {
          currencies.add(CurrencyInfo(key, value.toDouble()));
        });

        setState(() {});
      } else {
        throw Exception('Failed to load currency data');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _showFirstCurrencyModal(BuildContext context, String type) {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return _buildCurrencyList(choosenFirstCurrency, type, context);
      },
    );
  }

  Future<void> _showSecondCurrencyModal(BuildContext context, String type) {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return _buildCurrencyList(choosenSecondCurrency, type, context);
      },
    );
  }

  Widget _buildCurrencyList(
      int choosenCurrency, String type, BuildContext context) {
    return SizedBox(
      height: 300,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: ListView.builder(
          itemCount: currencies.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              tileColor: choosenCurrency == index ? Colors.purpleAccent : null,
              trailing:
                  choosenCurrency == index ? const Icon(Icons.check) : null,
              title: Text(currencies[index].name),
              onTap: () {
                setState(() {
                  if (choosenCurrency == choosenFirstCurrency) {
                    choosenFirstCurrency = index;
                  } else {
                    choosenSecondCurrency = index;
                  }
                });
                onTextChanging(
                    type, type == "first" ? _first.text : _second.text);
                Navigator.pop(context, currencies[index]);
              },
            );
          },
        ),
      ),
    );
  }

  void onTextChanging(String type, String value) {
    if (value.isEmpty) return;

    double amount = double.tryParse(value) ?? 0;
    double rateFromBaseCurrency = currencies[choosenFirstCurrency].price;
    double rateToBaseCurrency = currencies[choosenSecondCurrency].price;

    if (type == "first") {
      double result =
          convertCurrency(amount, rateFromBaseCurrency, rateToBaseCurrency);
      _second.text = result.toStringAsFixed(2);
    } else if (type == "second") {
      double result =
          convertCurrency(amount, rateToBaseCurrency, rateFromBaseCurrency);
      _first.text = result.toStringAsFixed(2);
    }
  }

  double convertCurrency(
    double amount,
    double rateFromBaseCurrency,
    double rateToBaseCurrency,
  ) {
    return amount * (1 / rateFromBaseCurrency) * rateToBaseCurrency;
  }

  @override
  void dispose() {
    _first.dispose();
    _second.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context)
            .colorScheme
            .primary
            .withBlue(255)
            .withOpacity(0.5),
        title: Text(widget.title),
      ),
      body: currencies.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(50.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(currencies[choosenFirstCurrency].name),
                        const SizedBox(width: 50),
                        Expanded(
                          child: TextField(
                            controller: _first,
                            textAlign: TextAlign.right,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Wprowadz ilość',
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 3,
                                  color: Colors.purpleAccent,
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              onTextChanging("first", value);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Row(
                      children: <Widget>[
                        Text(currencies[choosenSecondCurrency].name),
                        const SizedBox(width: 50),
                        Expanded(
                          child: TextField(
                            controller: _second,
                            textAlign: TextAlign.right,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9]'),
                              ),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Wprowadz ilość',
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 3,
                                  color: Colors.purpleAccent,
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              onTextChanging("second", value);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        GlassMorphismButton(
                          start: 0.5,
                          end: 0.9,
                          color: Colors.purpleAccent,
                          child: const Text("Wybiersz Pierwszą"),
                          onPressed: () =>
                              _showFirstCurrencyModal(context, "first"),
                        ),
                        const SizedBox(width: 50),
                        GlassMorphismButton(
                          start: 0.5,
                          end: 0.9,
                          color: Colors.purpleAccent,
                          child: const Text("Wybiersz Drugą"),
                          onPressed: () =>
                              _showSecondCurrencyModal(context, "second"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        const Text("Dla pierwszego"),
                        Slider(
                          value: _currentSliderValue,
                          max: 1000,
                          divisions: 100,
                          label: _currentSliderValue.round().toString(),
                          onChanged: (double value) {
                            setState(() {
                              _currentSliderValue = value;
                              if (_currentSliderSecondValue != 0) {
                                _currentSliderSecondValue = 0;
                              }
                              _first.text = value.toString();
                            });
                            onTextChanging("first", value.toString());
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text("Dla drugiego:"),
                        Slider(
                          value: _currentSliderSecondValue,
                          max: 1000,
                          divisions: 100,
                          label: _currentSliderSecondValue.round().toString(),
                          onChanged: (double value) {
                            setState(() {
                              _currentSliderSecondValue = value;
                              if (_currentSliderValue != 0) {
                                _currentSliderValue = 0;
                              }
                              _second.text = value.toString();
                            });
                            onTextChanging("second", value.toString());
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _dialogBuilder(context),
        tooltip: 'Increment',
        child: const Icon(Icons.info_outline),
      ),
    );
  }
}
