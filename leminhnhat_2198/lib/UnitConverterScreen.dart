import 'package:flutter/material.dart';

class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({Key? key}) : super(key: key);

  @override
  _UnitConverterScreenState createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  final TextEditingController _controller = TextEditingController();
  double? _convertedValue;
  String _fromUnit = 'Mét (m)';
  String _toUnit = 'Feet (ft)';
  String? _errorMessage;

  void _convertUnits() {
    setState(() {
      _errorMessage = null;
      final input = double.tryParse(_controller.text);

      if (_controller.text.isEmpty) {
        _errorMessage = 'Vui lòng nhập giá trị';
        _convertedValue = null;
        return;
      }

      if (input == null) {
        _errorMessage = 'Vui lòng nhập số hợp lệ';
        _convertedValue = null;
        return;
      }

      if (input < 0) {
        _errorMessage = 'Giá trị phải lớn hơn hoặc bằng 0';
        _convertedValue = null;
        return;
      }

      if (_fromUnit == _toUnit) {
        _errorMessage = 'Vui lòng chọn hai đơn vị khác nhau';
        _convertedValue = null;
        return;
      }

      // Chuyển đổi đơn vị chiều dài
      if (_fromUnit == 'Mét (m)' && _toUnit == 'Feet (ft)') {
        _convertedValue = input * 3.28084;
      } else if (_fromUnit == 'Feet (ft)' && _toUnit == 'Mét (m)') {
        _convertedValue = input / 3.28084;
      } else if (_fromUnit == 'Mét (m)' && _toUnit == 'Kilômét (km)') {
        _convertedValue = input / 1000;
      } else if (_fromUnit == 'Kilômét (km)' && _toUnit == 'Mét (m)') {
        _convertedValue = input * 1000;
      } else if (_fromUnit == 'Mét (m)' && _toUnit == 'Dặm (mile)') {
        _convertedValue = input * 0.000621371;
      } else if (_fromUnit == 'Dặm (mile)' && _toUnit == 'Mét (m)') {
        _convertedValue = input / 0.000621371;
      } else if (_fromUnit == 'Feet (ft)' && _toUnit == 'Kilômét (km)') {
        _convertedValue = input * 0.0003048;
      } else if (_fromUnit == 'Kilômét (km)' && _toUnit == 'Feet (ft)') {
        _convertedValue = input / 0.0003048;
      } else if (_fromUnit == 'Feet (ft)' && _toUnit == 'Dặm (mile)') {
        _convertedValue = input * 0.000189394;
      } else if (_fromUnit == 'Dặm (mile)' && _toUnit == 'Feet (ft)') {
        _convertedValue = input / 0.000189394;
      } else if (_fromUnit == 'Kilômét (km)' && _toUnit == 'Dặm (mile)') {
        _convertedValue = input * 0.621371;
      } else if (_fromUnit == 'Dặm (mile)' && _toUnit == 'Kilômét (km)') {
        _convertedValue = input / 0.621371;
      }
    });
  }

  String _getUnitSymbol(String unit) {
    if (unit.contains('Mét (m)')) return 'm';
    if (unit.contains('Feet (ft)')) return 'ft';
    if (unit.contains('Kilômét (km)')) return 'km';
    if (unit.contains('Dặm (mile)')) return 'mile';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chuyển đổi đơn vị đo'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Nhập giá trị cần chuyển đổi:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                hintText: 'Nhập giá trị',
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
                        items:
                            [
                                  'Mét (m)',
                                  'Feet (ft)',
                                  'Kilômét (km)',
                                  'Dặm (mile)',
                                ]
                                .map(
                                  (unit) => DropdownMenuItem(
                                    value: unit,
                                    child: Text(
                                      unit,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            _fromUnit = value!;
                            _convertedValue = null;
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
                    color: Colors.blue,
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
                        items:
                            [
                                  'Mét (m)',
                                  'Feet (ft)',
                                  'Kilômét (km)',
                                  'Dặm (mile)',
                                ]
                                .map(
                                  (unit) => DropdownMenuItem(
                                    value: unit,
                                    child: Text(
                                      unit,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            _toUnit = value!;
                            _convertedValue = null;
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
              onPressed: _convertUnits,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
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
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
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
                    _convertedValue == null
                        ? 'Chưa có kết quả'
                        : '${_controller.text} ${_getUnitSymbol(_fromUnit)} = ${_convertedValue!.toStringAsFixed(4)} ${_getUnitSymbol(_toUnit)}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _convertedValue == null
                          ? Colors.grey
                          : Colors.blue.shade800,
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
