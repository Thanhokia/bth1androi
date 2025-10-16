import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:mysql1/mysql1.dart';

// =================================================================
// PHẦN 1: MAIN - KHỞI CHẠY ỨNG DỤNG
// =================================================================

void main() {
  runApp(const OrderManagementApp());
}

class OrderManagementApp extends StatelessWidget {
  const OrderManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Sử dụng ChangeNotifierProvider để quản lý trạng thái của ứng dụng
    // OrderProvider sẽ cung cấp dữ liệu đơn hàng cho toàn bộ widget con
    return ChangeNotifierProvider(
      create: (context) => OrderProvider(),
      child: MaterialApp(
        title: 'Quản lý đơn hàng',
        theme: ThemeData(
          // useMaterial3: false, // Tắt M3 để tương thích với CardThemeData
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ).copyWith(
            secondary: Colors.orangeAccent,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 4,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.orangeAccent,
          ),
          cardTheme: CardThemeData( // SỬA: Đổi CardTheme thành CardThemeData
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(fontSize: 16),
            titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        home: const OrderListScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// =================================================================
// PHẦN 2: MODEL - ĐỊNH NGHĨA CẤU TRÚC DỮ LIỆU ĐƠN HÀNG
// =================================================================

class Order {
  final String id;
  String customerName;
  String phoneNumber;
  String address;
  String? notes;
  DateTime deliveryDate;
  String paymentMethod;
  List<String> products;

  Order({
    String? id,
    required this.customerName,
    required this.phoneNumber,
    required this.address,
    this.notes,
    required this.deliveryDate,
    required this.paymentMethod,
    required this.products,
  }) : id = id ?? const Uuid().v4(); // Tự động tạo ID nếu không được cung cấp

  // Chuyển đổi từ đối tượng Order sang Map để lưu vào database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerName': customerName,
      'phoneNumber': phoneNumber,
      'address': address,
      'notes': notes,
      'deliveryDate': deliveryDate.toIso8601String(),
      'paymentMethod': paymentMethod,
      'products': jsonEncode(products), // Chuyển danh sách sản phẩm thành chuỗi JSON
    };
  }

  // Chuyển đổi từ Map (đọc từ database) sang đối tượng Order
  factory Order.fromMap(Map<String, dynamic> map) {
    // Đảm bảo các trường không null trước khi parse
    final deliveryDateStr = map['deliveryDate']?.toString();
    final productsStr = map['products']?.toString();

    return Order(
      id: map['id'] ?? '',
      customerName: map['customerName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      address: map['address'] ?? '',
      notes: map['notes'],
      deliveryDate: deliveryDateStr != null ? DateTime.parse(deliveryDateStr) : DateTime.now(),
      paymentMethod: map['paymentMethod'] ?? '',
      products: productsStr != null ? List<String>.from(jsonDecode(productsStr)) : [], // Giải mã chuỗi JSON
    );
  }
}


// =================================================================
// PHẦN 3: DATABASE HELPER - XỬ LÝ TRUY VẤN VỚI MYSQL
// =================================================================

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // THAY ĐỔI: Cấu hình thông tin kết nối tới MySQL server của bạn
  final ConnectionSettings _connectionSettings = ConnectionSettings( // SỬA: Bỏ 'const'
    host: '10.0.2.2', // Dùng 10.0.2.2 nếu chạy app trên Android Emulator và MySQL server trên localhost
    port: 3306,
    user: 'root', // Thay bằng user của bạn
    password: 'your_password', // Thay bằng password của bạn
    db: 'order_db', // Thay bằng tên database của bạn
  );

  // Lấy kết nối tới database
  Future<MySqlConnection> get _connection async {
    return await MySqlConnection.connect(_connectionSettings);
  }

  // Hàm này đảm bảo bảng 'orders' tồn tại trong database
  Future<void> ensureTableExists() async {
    final conn = await _connection;
    try {
      await conn.query('''
        CREATE TABLE IF NOT EXISTS orders (
          id VARCHAR(255) PRIMARY KEY,
          customerName TEXT NOT NULL,
          phoneNumber VARCHAR(20) NOT NULL,
          address TEXT NOT NULL,
          notes TEXT,
          deliveryDate DATETIME NOT NULL,
          paymentMethod VARCHAR(50) NOT NULL,
          products TEXT NOT NULL
        )
      ''');
    } catch (e) {
      debugPrint("Error creating table: $e");
    } finally {
      await conn.close();
    }
  }

  // Lấy tất cả đơn hàng
  Future<List<Order>> getOrders() async {
    final conn = await _connection;
    try {
      final results = await conn.query('SELECT * FROM orders ORDER BY deliveryDate DESC');
      return results.map((row) => Order.fromMap(row.fields)).toList();
    } catch (e) {
      debugPrint("Error getting orders: $e");
      return [];
    } finally {
      await conn.close();
    }
  }

  // Thêm một đơn hàng mới
  Future<void> insertOrder(Order order) async {
    final conn = await _connection;
    try {
      final orderMap = order.toMap();
      await conn.query(
        'INSERT INTO orders (id, customerName, phoneNumber, address, notes, deliveryDate, paymentMethod, products) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        [
          orderMap['id'],
          orderMap['customerName'],
          orderMap['phoneNumber'],
          orderMap['address'],
          orderMap['notes'],
          orderMap['deliveryDate'],
          orderMap['paymentMethod'],
          orderMap['products'],
        ],
      );
    } catch (e) {
      debugPrint("Error inserting order: $e");
    } finally {
      await conn.close();
    }
  }

  // Cập nhật một đơn hàng
  Future<void> updateOrder(Order order) async {
    final conn = await _connection;
    try {
      final orderMap = order.toMap();
      await conn.query(
        'UPDATE orders SET customerName = ?, phoneNumber = ?, address = ?, notes = ?, deliveryDate = ?, paymentMethod = ?, products = ? WHERE id = ?',
        [
          orderMap['customerName'],
          orderMap['phoneNumber'],
          orderMap['address'],
          orderMap['notes'],
          orderMap['deliveryDate'],
          orderMap['paymentMethod'],
          orderMap['products'],
          orderMap['id'],
        ],
      );
    } catch (e) {
      debugPrint("Error updating order: $e");
    } finally {
      await conn.close();
    }
  }

  // Xóa một đơn hàng
  Future<void> deleteOrder(String id) async {
    final conn = await _connection;
    try {
      await conn.query('DELETE FROM orders WHERE id = ?', [id]);
    } catch (e) {
      debugPrint("Error deleting order: $e");
    } finally {
      await conn.close();
    }
  }
}

// =================================================================
// PHẦN 4: PROVIDER - QUẢN LÝ TRẠNG THÁI ỨNG DỤNG
// =================================================================

class OrderProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Order> _orders = [];
  String _searchQuery = '';

  List<Order> get orders {
    if (_searchQuery.isEmpty) {
      return _orders;
    } else {
      return _orders
          .where((order) =>
          order.customerName.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
  }

  OrderProvider() {
    // Đảm bảo bảng tồn tại trước khi tải dữ liệu
    _dbHelper.ensureTableExists().then((_) => loadOrders());
  }

  // Tải danh sách đơn hàng từ database
  Future<void> loadOrders() async {
    _orders = await _dbHelper.getOrders();
    notifyListeners();
  }

  // Thêm đơn hàng
  Future<void> addOrder(Order order) async {
    await _dbHelper.insertOrder(order);
    await loadOrders();
  }

  // Cập nhật đơn hàng
  Future<void> updateOrder(Order order) async {
    await _dbHelper.updateOrder(order);
    await loadOrders();
  }

  // Xóa đơn hàng
  Future<void> deleteOrder(String id) async {
    await _dbHelper.deleteOrder(id);
    await loadOrders();
  }

  // Cập nhật query tìm kiếm
  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}

// =================================================================
// PHẦN 5: UI - MÀN HÌNH DANH SÁCH ĐƠN HÀNG (ORDER LIST SCREEN)
// =================================================================

class OrderListScreen extends StatelessWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách đơn hàng'),
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Tìm kiếm theo tên khách hàng',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                Provider.of<OrderProvider>(context, listen: false).search(value);
              },
            ),
          ),
          // Danh sách đơn hàng
          Expanded(
            child: Consumer<OrderProvider>(
              builder: (context, provider, child) {
                if (provider.orders.isEmpty) {
                  return const Center(
                    child: Text(
                      'Chưa có đơn hàng nào.\nNhấn nút + để tạo đơn hàng mới.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: provider.orders.length,
                  itemBuilder: (context, index) {
                    final order = provider.orders[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: const Icon(Icons.receipt, color: Colors.white),
                        ),
                        title: Text(
                          order.customerName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Ngày giao: ${DateFormat('dd/MM/yyyy').format(order.deliveryDate)}\n${order.paymentMethod}',
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red[400]),
                          onPressed: () => _confirmDelete(context, order.id),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailScreen(order: order),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditOrderScreen()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Tạo đơn hàng mới',
      ),
    );
  }

  // Hiển thị dialog xác nhận xóa
  void _confirmDelete(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa đơn hàng này không?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Xóa'),
              onPressed: () {
                Provider.of<OrderProvider>(context, listen: false).deleteOrder(orderId);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa đơn hàng')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

// =================================================================
// PHẦN 6: UI - MÀN HÌNH TẠO/SỬA ĐƠN HÀNG (ADD/EDIT ORDER SCREEN)
// =================================================================

class AddEditOrderScreen extends StatefulWidget {
  final Order? order;

  const AddEditOrderScreen({super.key, this.order});

  @override
  State<AddEditOrderScreen> createState() => _AddEditOrderScreenState();
}

class _AddEditOrderScreenState extends State<AddEditOrderScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers cho các trường text
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _notesController;

  // Biến lưu trạng thái của form
  DateTime _deliveryDate = DateTime.now();
  String _paymentMethod = 'Tiền mặt';
  List<String> _selectedProducts = [];

  // Danh sách sản phẩm mẫu
  final List<String> _availableProducts = [
    'iPhone 15 Pro Max',
    'Samsung Galaxy S24 Ultra',
    'Macbook Pro M3',
    'Dell XPS 15',
    'Sony WH-1000XM5',
    'Bàn phím cơ Keychron Q1'
  ];

  @override
  void initState() {
    super.initState();
    // Nếu là chế độ sửa, gán giá trị cũ vào các controller
    _nameController = TextEditingController(text: widget.order?.customerName);
    _phoneController = TextEditingController(text: widget.order?.phoneNumber);
    _addressController = TextEditingController(text: widget.order?.address);
    _notesController = TextEditingController(text: widget.order?.notes);
    if (widget.order != null) {
      _deliveryDate = widget.order!.deliveryDate;
      _paymentMethod = widget.order!.paymentMethod;
      _selectedProducts = List<String>.from(widget.order!.products);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Hàm hiển thị DatePicker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deliveryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _deliveryDate) {
      setState(() {
        _deliveryDate = picked;
      });
    }
  }

  // Hàm hiển thị dialog chọn nhiều sản phẩm
  void _showProductSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final tempSelectedProducts = List<String>.from(_selectedProducts);
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Chọn sản phẩm'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _availableProducts.length,
                  itemBuilder: (context, index) {
                    final product = _availableProducts[index];
                    return CheckboxListTile(
                      title: Text(product),
                      value: tempSelectedProducts.contains(product),
                      onChanged: (bool? value) {
                        setStateDialog(() {
                          if (value == true) {
                            tempSelectedProducts.add(product);
                          } else {
                            tempSelectedProducts.remove(product);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedProducts = tempSelectedProducts;
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Hàm xử lý lưu đơn hàng
  void _saveOrder() {
    if (_formKey.currentState!.validate()) {
      // Kiểm tra đã chọn sản phẩm chưa
      if (_selectedProducts.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng chọn ít nhất một sản phẩm'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final orderData = Order(
        id: widget.order?.id,
        customerName: _nameController.text,
        phoneNumber: _phoneController.text,
        address: _addressController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        deliveryDate: _deliveryDate,
        paymentMethod: _paymentMethod,
        products: _selectedProducts,
      );

      final provider = Provider.of<OrderProvider>(context, listen: false);
      if (widget.order == null) {
        provider.addOrder(orderData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã tạo đơn hàng mới!')),
        );
      } else {
        provider.updateOrder(orderData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật đơn hàng!')),
        );
      }
      // Thoát khỏi màn hình sau khi lưu
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.order == null ? 'Tạo đơn hàng mới' : 'Chỉnh sửa đơn hàng'),
        actions: [
          IconButton(
            onPressed: _saveOrder,
            icon: const Icon(Icons.save),
            tooltip: 'Lưu đơn hàng',
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên khách hàng
                _buildSectionTitle('Thông tin khách hàng'),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Tên khách hàng'),
                  validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập tên khách hàng' : null,
                ),
                const SizedBox(height: 16),
                // Số điện thoại
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Số điện thoại'),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số điện thoại';
                    }
                    if (value.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'Số điện thoại không hợp lệ (cần 10 chữ số)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Địa chỉ
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Địa chỉ giao hàng'),
                  maxLines: 2,
                  validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập địa chỉ' : null,
                ),
                const SizedBox(height: 16),
                // Ghi chú
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'Ghi chú (tùy chọn)'),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),

                // Thông tin đơn hàng
                _buildSectionTitle('Thông tin đơn hàng'),
                // Ngày giao
                Row(
                  children: [
                    const Text('Ngày giao dự kiến: ', style: TextStyle(fontSize: 16)),
                    Text(
                      DateFormat('dd/MM/yyyy').format(_deliveryDate),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    )
                  ],
                ),
                const SizedBox(height: 16),

                // Phương thức thanh toán
                const Text('Phương thức thanh toán:', style: TextStyle(fontSize: 16)),
                RadioListTile<String>(
                  title: const Text('Tiền mặt'),
                  value: 'Tiền mặt',
                  groupValue: _paymentMethod,
                  onChanged: (value) => setState(() => _paymentMethod = value!),
                ),
                RadioListTile<String>(
                  title: const Text('Chuyển khoản'),
                  value: 'Chuyển khoản',
                  groupValue: _paymentMethod,
                  onChanged: (value) => setState(() => _paymentMethod = value!),
                ),
                const SizedBox(height: 16),

                // Danh sách sản phẩm
                ListTile(
                  title: const Text('Danh sách sản phẩm'),
                  subtitle: Text(_selectedProducts.isEmpty
                      ? 'Chưa chọn sản phẩm nào'
                      : _selectedProducts.join(', ')),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: _showProductSelectionDialog,
                ),
                const SizedBox(height: 32),

                // Nút lưu
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveOrder,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: const Text('Lưu đơn hàng'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget helper để tạo tiêu đề cho mỗi phần
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

// =================================================================
// PHẦN 7: UI - MÀN HÌNH CHI TIẾT ĐƠN HÀNG (ORDER DETAIL SCREEN)
// =================================================================

class OrderDetailScreen extends StatelessWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đơn hàng'),
        actions: [
          // Nút chỉnh sửa
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditOrderScreen(order: order),
                ),
              );
            },
          ),
          // Nút xóa
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context, order),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailCard(
              context,
              'Mã đơn hàng',
              order.id,
              Icons.qr_code_scanner,
            ),
            _buildDetailCard(
              context,
              'Thông tin khách hàng',
              [
                _buildDetailRow('Tên:', order.customerName),
                _buildDetailRow('SĐT:', order.phoneNumber),
                _buildDetailRow('Địa chỉ:', order.address),
                if (order.notes != null && order.notes!.isNotEmpty)
                  _buildDetailRow('Ghi chú:', order.notes!),
              ].join('\n'),
              Icons.person,
            ),
            _buildDetailCard(
              context,
              'Thông tin giao hàng',
              [
                _buildDetailRow('Ngày giao:', DateFormat('dd/MM/yyyy').format(order.deliveryDate)),
                _buildDetailRow('Thanh toán:', order.paymentMethod),
              ].join('\n'),
              Icons.local_shipping,
            ),
            _buildDetailCard(
              context,
              'Danh sách sản phẩm',
              order.products.map((p) => '• $p').join('\n'),
              Icons.inventory,
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper để tạo một thẻ chi tiết
  Widget _buildDetailCard(BuildContext context, String title, String content, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).primaryColor, size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    content,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildDetailRow(String label, String value) {
    return '$label $value';
  }

  // Hàm xác nhận xóa
  void _confirmDelete(BuildContext context, Order orderToDelete) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa đơn hàng này không?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Xóa'),
              onPressed: () {
                Provider.of<OrderProvider>(context, listen: false).deleteOrder(orderToDelete.id);
                Navigator.of(ctx).pop(); // Đóng dialog
                Navigator.of(context).pop(); // Quay lại màn hình danh sách
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa đơn hàng')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

