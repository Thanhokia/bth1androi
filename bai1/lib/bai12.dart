import 'package:flutter/material.dart';
import 'models/product.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Danh sách sản phẩm",
      home: ProductListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ProductListScreen extends StatelessWidget {
  // Danh sách sản phẩm mẫu
  final List<Product> products = [
    Product("assets/images/wallet.jpg", "Ví nam mini đựng thẻ VS22 chất da Saffiano",
        "255.000 VND", 4.0, "12 views", ["HOA HỒNG", "XTRA"]),
    Product("assets/images/bag.jpg", "Túi đeo chéo LEACAT polyester chống thấm nước",
        "315.000 VND", 5.0, "1.3k views", ["XTRA"]),
    Product("assets/images/cafr.jpg", "Phin cafe Trung Nguyên - nhôm cá nhân cao cấp",
        "28.000 VND", 4.5, "12.2k views", ["HOA HỒNG"]),
    Product("assets/images/leatherbag.jpg", "Ví da cầm tay mềm mại cỡ lớn thời trang",
        "610.000 VND", 5.0, "56 views", ["HOA HỒNG", "XTRA"]),
    Product("assets/images/shoes.jpg", "Dép nữ đế bằng phong cách trẻ trung",
        "120.000 VND", 4.3, "2.1k views", ["XTRA"]),
    Product("assets/images/earbuds.jpg", "Tai nghe Bluetooth M10 pin trâu",
        "159.000 VND", 4.7, "8.6k views", ["HOA HỒNG"]),
  ];

  // Widget build nhãn
  Widget buildLabels(List<String> labels) {
    return Row(
      children: labels.map((label) {
        Color bgColor = label == "HOA HỒNG" ? Colors.red : Colors.blue;
        return Container(
          margin: const EdgeInsets.only(right: 4),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DANH SÁCH SẢN PHẨM"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 cột
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.65, // tỷ lệ khung sản phẩm
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              elevation: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Image.asset(product.image,
                        fit: BoxFit.cover, width: double.infinity),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: buildLabels(product.labels), // Nhãn
                  ),
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                    child: Text(
                      product.price,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        const Icon(Icons.star,
                            color: Colors.orange, size: 14),
                        Text("${product.rating}",
                            style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 8),
                        Text(product.sold,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}