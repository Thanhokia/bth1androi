import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Order {
  String customerName;
  String customerEmail;
  String customerPhone;
  String province;
  String district;
  String ward;
  String addressDetails;
  String paymentMethod;
  String note;
  DateTime createdAt;
  String status;

  Order({
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.province,
    required this.district,
    required this.ward,
    required this.addressDetails,
    required this.paymentMethod,
    required this.note,
    required this.createdAt,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        'customerName': customerName,
        'customerEmail': customerEmail,
        'customerPhone': customerPhone,
        'province': province,
        'district': district,
        'ward': ward,
        'addressDetails': addressDetails,
        'paymentMethod': paymentMethod,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
        'status': status,
      };

  static Order fromJson(Map<String, dynamic> json) => Order(
        customerName: json['customerName'],
        customerEmail: json['customerEmail'],
        customerPhone: json['customerPhone'],
        province: json['province'],
        district: json['district'],
        ward: json['ward'],
        addressDetails: json['addressDetails'],
        paymentMethod: json['paymentMethod'],
        note: json['note'],
        createdAt: DateTime.parse(json['createdAt']),
        status: json['status'],
      );
}

class OrderWizardScreen extends StatefulWidget {
  const OrderWizardScreen({super.key});

  @override
  State<OrderWizardScreen> createState() => _OrderWizardScreenState();
}

class _OrderWizardScreenState extends State<OrderWizardScreen> {
  int _currentStep = 0;

  // Step 1
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // Step 2
  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedWard;
  final _addressDetailsController = TextEditingController();

  // Step 3
  String _paymentMethod = 'Tiền mặt';
  final _noteController = TextEditingController();

  // Sample data
  final Map<String, List<String>> _provincesToDistricts = {
    'Hà Nội': ['Ba Đình', 'Hoàn Kiếm', 'Hai Bà Trưng'],
    'TP. Hồ Chí Minh': ['Quận 1', 'Quận 3', 'Bình Thạnh'],
  };
  final Map<String, List<String>> _districtsToWards = {
    'Ba Đình': ['Phúc Xá', 'Trúc Bạch', 'Hàng Buồm'],
    'Hoàn Kiếm': ['Hàng Bạc', 'Hàng Đào', 'Hàng Bồ'],
    'Hai Bà Trưng': ['Bạch Đằng', 'Tràng Tiền', 'Phố Huế'],
    'Quận 1': ['Bến Nghé', 'Cô Giang', 'Đa Kao'],
    'Quận 3': ['Võ Thị Sáu', '14/3', '7 Vườn'],
    'Bình Thạnh': ['1', '2', '3'],
  };

  List<String> _getDistricts() {
    return _selectedProvince != null ? _provincesToDistricts[_selectedProvince!] ?? [] : [];
  }
  List<String> _getWards() {
    return _selectedDistrict != null ? _districtsToWards[_selectedDistrict!] ?? [] : [];
  }

  void _onStepContinue() {
    if (_currentStep == 0) {
      if (_nameController.text.isEmpty ||
          _emailController.text.isEmpty ||
          _phoneController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập đủ thông tin khách hàng')));
        return;
      }
      setState(() => _currentStep++);
    } else if (_currentStep == 1) {
      if (_selectedProvince == null ||
          _selectedDistrict == null ||
          _selectedWard == null ||
          _addressDetailsController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập đủ địa chỉ giao hàng')));
        return;
      }
      setState(() => _currentStep++);
    } else if (_currentStep == 2) {
      _saveOrder();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  Future<void> _saveOrder() async {
    final order = Order(
      customerName: _nameController.text,
      customerEmail: _emailController.text,
      customerPhone: _phoneController.text,
      province: _selectedProvince ?? '',
      district: _selectedDistrict ?? '',
      ward: _selectedWard ?? '',
      addressDetails: _addressDetailsController.text,
      paymentMethod: _paymentMethod,
      note: _noteController.text,
      createdAt: DateTime.now(),
      status: 'Đã xác nhận',
    );
    final prefs = await SharedPreferences.getInstance();
    final ordersData = prefs.getString('orders');
    List orders = ordersData != null ? json.decode(ordersData) : [];
    orders.add(order.toJson());
    await prefs.setString('orders', json.encode(orders));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => OrderDetailsScreen(order: order),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đặt đơn hàng')),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        steps: [
          Step(
            title: const Text('Thông tin khách hàng'),
            isActive: _currentStep >= 0,
            content: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Tên khách hàng'),
                ),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Số điện thoại'),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Địa chỉ giao hàng'),
            isActive: _currentStep >= 1,
            content: Column(
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Tỉnh/Thành phố'),
                  value: _selectedProvince,
                  items: _provincesToDistricts.keys
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedProvince = val;
                      _selectedDistrict = null;
                      _selectedWard = null;
                    });
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Quận/Huyện'),
                  value: _selectedDistrict,
                  items: _getDistricts()
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedDistrict = val;
                      _selectedWard = null;
                    });
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Phường/Xã'),
                  value: _selectedWard,
                  items: _getWards()
                      .map((w) => DropdownMenuItem(value: w, child: Text(w)))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedWard = val;
                    });
                  },
                ),
                TextField(
                  controller: _addressDetailsController,
                  decoration: const InputDecoration(labelText: 'Địa chỉ chi tiết'),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Thanh toán & xác nhận'),
            isActive: _currentStep >= 2,
            content: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Tiền mặt'),
                        value: 'Tiền mặt',
                        groupValue: _paymentMethod,
                        onChanged: (val) => setState(() => _paymentMethod = val!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Thẻ'),
                        value: 'Thẻ',
                        groupValue: _paymentMethod,
                        onChanged: (val) => setState(() => _paymentMethod = val!),
                      ),
                    ),
                  ],
                ),
                TextField(
                  controller: _noteController,
                  decoration: const InputDecoration(labelText: 'Ghi chú đơn hàng'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saveOrder,
                  child: const Text('Xác nhận đơn'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OrderDetailsScreen extends StatelessWidget {
  final Order order;
  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết đơn hàng')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tên khách hàng: ${order.customerName}'),
            Text('Email: ${order.customerEmail}'),
            Text('Số điện thoại: ${order.customerPhone}'),
            Text('Địa chỉ: ${order.addressDetails}, ${order.ward}, ${order.district}, ${order.province}'),
            Text('Phương thức thanh toán: ${order.paymentMethod}'),
            Text('Ghi chú: ${order.note}'),
            Text('Ngày đặt: ${order.createdAt.toLocal()}'),
            Text('Trạng thái: ${order.status}'),
          ],
        ),
      ),
    );
  }
}

