import 'package:flutter/material.dart';

class SelectInput extends StatefulWidget {
  const SelectInput({super.key, required this.country, this.countrySelect});

  final List<String> country;
  final String? countrySelect;

  @override
  _SelectInputState createState() => _SelectInputState();
}

class _SelectInputState extends State<SelectInput> {
  String? selectedValue; // To hold the selected value
  String? countrySelect; // To hold the selected value

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DropdownButton<String>(
        hint: const Text("Select an option"), // Placeholder text
        value: selectedValue,
        items: (widget.country)
            .map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedValue = newValue; // Update the selected value
            countrySelect = newValue;
          });
        },
      ),
    );
  }
}

