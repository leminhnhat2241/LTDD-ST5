import 'package:flutter/material.dart';

class TemperatureConverterScreen extends StatefulWidget {
  @override
  _TemperatureConverterScreenState createState() =>
      _TemperatureConverterScreenState();
}

class _TemperatureConverterScreenState
    extends State<TemperatureConverterScreen> {
  final TextEditingController _controller = TextEditingController();
  double? _convertedTemperature;
  String _fromUnit = 'Celsius';
  String _toUnit = 'Fahrenheit';
  String? _errorMessage;

  void _convertTemperature() {
    setState(() {
      _errorMessage = null;
      final input = double.tryParse(_controller.text);

      if (_controller.text.isEmpty) {
        _errorMessage = 'Vui lòng nhập nhiệt độ';
        _convertedTemperature = null;
        return;
      }

      if (input == null) {
        _errorMessage = 'Vui lòng nhập số hợp lệ';
        _convertedTemperature = null;
        return;
      }

      if (_fromUnit == _toUnit) {
        _errorMessage = 'Vui lòng chọn hai đơn vị khác nhau';
        _convertedTemperature = null;
        return;
      }

      // Chuyển đổi nhiệt độ
      if (_fromUnit == 'Celsius' && _toUnit == 'Fahrenheit') {
        _convertedTemperature = input * 9 / 5 + 32;
      } else if (_fromUnit == 'Fahrenheit' && _toUnit == 'Celsius') {
        _convertedTemperature = (input - 32) * 5 / 9;
      } else if (_fromUnit == 'Celsius' && _toUnit == 'Kelvin') {
        _convertedTemperature = input + 273.15;
      } else if (_fromUnit == 'Kelvin' && _toUnit == 'Celsius') {
        _convertedTemperature = input - 273.15;
      } else if (_fromUnit == 'Fahrenheit' && _toUnit == 'Kelvin') {
        _convertedTemperature = (input - 32) * 5 / 9 + 273.15;
      } else if (_fromUnit == 'Kelvin' && _toUnit == 'Fahrenheit') {
        _convertedTemperature = (input - 273.15) * 9 / 5 + 32;
      }
    });
  }

  String _getUnitSymbol(String unit) {
    switch (unit) {
      case 'Celsius':
        return '°C';
      case 'Fahrenheit':
        return '°F';
      case 'Kelvin':
        return 'K';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chuyển đổi nhiệt độ'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Nhập nhiệt độ cần chuyển đổi:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                hintText: 'Nhập giá trị nhiệt độ',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
                suffixText: _getUnitSymbol(_fromUnit),
                errorText: _errorMessage,
              ),
              onChanged: (value) {
                if (_errorMessage != null) {
                  setState(() {
                    _errorMessage = null;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Từ:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _fromUnit,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: ['Celsius', 'Fahrenheit', 'Kelvin']
                            .map(
                              (unit) => DropdownMenuItem(
                                value: unit,
                                child: Text(unit),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _fromUnit = value!;
                            _convertedTemperature = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                const Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: Icon(
                    Icons.arrow_forward,
                    size: 30,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sang:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _toUnit,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: ['Celsius', 'Fahrenheit', 'Kelvin']
                            .map(
                              (unit) => DropdownMenuItem(
                                value: unit,
                                child: Text(unit),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _toUnit = value!;
                            _convertedTemperature = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _convertTemperature,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Chuyển đổi',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                children: [
                  const Text(
                    'Kết quả:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _convertedTemperature == null
                        ? 'Chưa có kết quả'
                        : '${_controller.text} ${_getUnitSymbol(_fromUnit)} = ${_convertedTemperature!.toStringAsFixed(2)} ${_getUnitSymbol(_toUnit)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _convertedTemperature == null
                          ? Colors.grey
                          : Colors.orange.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
