// lib/add_address_screen.dart
import 'package:flutter/material.dart';

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({super.key});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  // Controllers
  final TextEditingController _recipientNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressDetailsController = TextEditingController();

  // Dropdown selections
  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedWard;

  // Location
  double? _lat;
  double? _lng;
  String _locationText = 'No location selected';

  // Sample data for Vietnam provinces, districts, wards (hardcoded for demo - bạn có thể mở rộng)
  final Map<String, List<String>> _provincesToDistricts = {
    'Hà Nội': ['Ba Đình', 'Hoàn Kiếm', 'Hai Bà Trưng'],
    'TP. Hồ Chí Minh': ['Quận 1', 'Quận 3', 'Bình Thạnh'],
    // Thêm tỉnh khác nếu cần: 'Đà Nẵng': ['Hải Châu', 'Thanh Khê'], ...
  };

  final Map<String, List<String>> _districtsToWards = {
    'Ba Đình': ['Phúc Xá', 'Trúc Bạch', 'Hàng Buồm'],
    'Hoàn Kiếm': ['Hàng Bạc', 'Hàng Đào', 'Hàng Bồ'],
    'Hai Bà Trưng': ['Bạch Đằng', 'Tràng Tiền', 'Phố Huế'],
    'Quận 1': ['Bến Nghé', 'Cô Giang', 'Đa Kao'],
    'Quận 3': ['Võ Thị Sáu', '14/3', '7 Vườn'],
    'Bình Thạnh': ['1', '2', '3'],
    // Thêm phường khác nếu cần...
  };

  List<String> _getDistricts() {
    return _selectedProvince != null ? _provincesToDistricts[_selectedProvince!] ?? [] : [];
  }

  List<String> _getWards() {
    return _selectedDistrict != null ? _districtsToWards[_selectedDistrict!] ?? [] : [];
  }

  void _selectLocationOnMap() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('Select Location on Map', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map, size: 50, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Map would be displayed here', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Search for a location...',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.search),
                        ),
                        onFieldSubmitted: (value) {
                          // Mock search - thực tế dùng Google Places API
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Searching for: $value')),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        // Mock search button
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Search triggered!')),
                        );
                      },
                      child: const Text('Search'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Mock confirm - thực tế lấy lat/lng từ map pin
                        setState(() {
                          _lat = 21.0285; // Mock Hà Nội
                          _lng = 105.8542;
                          _locationText = 'Selected: Hà Nội (21.0285, 105.8542)';
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Location confirmed!')),
                        );
                      },
                      child: const Text('Confirm Location'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _validateForm() {
    if (_recipientNameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _selectedProvince == null ||
        _selectedDistrict == null ||
        _selectedWard == null ||
        _addressDetailsController.text.isEmpty) {
      _showError('All fields are required except map location.');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _saveAddress() {
    if (!_validateForm()) return;

    // Tạo object địa chỉ (thực tế lưu DB/API)
    final address = {
      'recipientName': _recipientNameController.text,
      'phone': _phoneController.text,
      'province': _selectedProvince!,
      'district': _selectedDistrict!,
      'ward': _selectedWard!,
      'details': _addressDetailsController.text,
      'lat': _lat,
      'lng': _lng,
    };

    // Mock lưu - print ra console (thực tế: dùng SharedPreferences hoặc Firebase)
    print('Saved Address: $address');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Address saved successfully!'), backgroundColor: Colors.green),
    );

    // Thực tế: Navigate về list địa chỉ
    // Navigator.pop(context); // Nếu gọi từ màn khác
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Address'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _recipientNameController,
                decoration: const InputDecoration(
                  labelText: 'Recipient Name',
                  hintText: 'Enter recipient name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter phone number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedProvince,
                decoration: const InputDecoration(
                  labelText: 'Province/City',
                  border: OutlineInputBorder(),
                ),
                items: _provincesToDistricts.keys.map((String province) {
                  return DropdownMenuItem<String>(value: province, child: Text(province));
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedProvince = newValue;
                    _selectedDistrict = null;
                    _selectedWard = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedDistrict,
                decoration: const InputDecoration(
                  labelText: 'District',
                  border: OutlineInputBorder(),
                ),
                items: _getDistricts().map((String district) {
                  return DropdownMenuItem<String>(value: district, child: Text(district));
                }).toList(),
                onChanged: _selectedProvince == null ? null : (String? newValue) {
                  setState(() {
                    _selectedDistrict = newValue;
                    _selectedWard = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedWard,
                decoration: const InputDecoration(
                  labelText: 'Ward',
                  border: OutlineInputBorder(),
                ),
                items: _getWards().map((String ward) {
                  return DropdownMenuItem<String>(value: ward, child: Text(ward));
                }).toList(),
                onChanged: _selectedDistrict == null ? null : (String? newValue) {
                  setState(() {
                    _selectedWard = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressDetailsController,
                decoration: const InputDecoration(
                  labelText: 'Address Details',
                  hintText: 'Enter detailed address',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectLocationOnMap,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Location on Map',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.map),
                  ),
                  child: Text(_locationText),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: _saveAddress,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                    child: const Text('Save Address', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}