import 'package:flutter/material.dart';
import '../models/survey_data.dart';
import '../services/file_manager.dart';

class DataMapScreen extends StatefulWidget {
  const DataMapScreen({super.key});

  @override
  State<DataMapScreen> createState() => _DataMapScreenState();
}

class _DataMapScreenState extends State<DataMapScreen> {
  final FileManager _fileManager = FileManager();
  
  List<SurveyData> _surveyDataList = [];
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic>? _dataStatistics;

  @override
  void initState() {
    super.initState();
    _loadSurveyData();
  }

  Future<void> _loadSurveyData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Load data using FileManager
      _surveyDataList = await _fileManager.loadAllSurveyData();
      
      // Sort by timestamp (newest first)
      _surveyDataList.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      // Get data statistics
      _dataStatistics = await _fileManager.getDataStatistics();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Lỗi khi tải dữ liệu: $e';
      });
    }
  }

  Color _getLightColor(double intensity) {
    if (intensity < 100) return Colors.grey;
    if (intensity < 300) return Colors.yellow[300]!;
    if (intensity < 600) return Colors.yellow[600]!;
    return Colors.yellow[900]!;
  }

  Color _getAccelerationColor(double magnitude) {
    if (magnitude < 5) return Colors.green;
    if (magnitude < 10) return Colors.orange;
    if (magnitude < 15) return Colors.red[300]!;
    return Colors.red[900]!;
  }

  Color _getMagneticColor(double magnitude) {
    if (magnitude < 20) return Colors.blue[300]!;
    if (magnitude < 40) return Colors.blue[600]!;
    if (magnitude < 60) return Colors.blue[800]!;
    return Colors.blue[900]!;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _showDataStatistics() async {
    if (_dataStatistics == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thống kê Dữ liệu'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Tổng số bản ghi: ${_dataStatistics!['totalRecords']}'),
              Text('Kích thước file: ${(_dataStatistics!['fileSize'] / 1024).toStringAsFixed(1)} KB'),
              if (_dataStatistics!['dateRange'] != null) ...[
                const SizedBox(height: 8),
                const Text('Khoảng thời gian:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Từ: ${_formatDateTime(_dataStatistics!['dateRange']['earliest'])}'),
                Text('Đến: ${_formatDateTime(_dataStatistics!['dateRange']['latest'])}'),
              ],
              const SizedBox(height: 8),
              const Text('Cường độ Ánh sáng:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Min: ${_dataStatistics!['lightIntensity']['min'].toStringAsFixed(1)} lux'),
              Text('Max: ${_dataStatistics!['lightIntensity']['max'].toStringAsFixed(1)} lux'),
              Text('Trung bình: ${_dataStatistics!['lightIntensity']['avg'].toStringAsFixed(1)} lux'),
              const SizedBox(height: 8),
              const Text('Độ Năng động:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Min: ${_dataStatistics!['accelerationMagnitude']['min'].toStringAsFixed(2)} m/s²'),
              Text('Max: ${_dataStatistics!['accelerationMagnitude']['max'].toStringAsFixed(2)} m/s²'),
              Text('Trung bình: ${_dataStatistics!['accelerationMagnitude']['avg'].toStringAsFixed(2)} m/s²'),
              const SizedBox(height: 8),
              const Text('Cường độ Từ trường:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Min: ${_dataStatistics!['magneticFieldMagnitude']['min'].toStringAsFixed(2)} μT'),
              Text('Max: ${_dataStatistics!['magneticFieldMagnitude']['max'].toStringAsFixed(2)} μT'),
              Text('Trung bình: ${_dataStatistics!['magneticFieldMagnitude']['avg'].toStringAsFixed(2)} μT'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleMenuAction(String action) async {
    switch (action) {
      case 'clear':
        await _clearAllData();
        break;
      case 'export':
        await _exportData();
        break;
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc chắn muốn xóa tất cả dữ liệu? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _fileManager.clearAllData();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa tất cả dữ liệu')),
        );
        _loadSurveyData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi khi xóa dữ liệu')),
        );
      }
    }
  }

  Future<void> _exportData() async {
    try {
      final filePath = await _fileManager.getFilePath();
      if (filePath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dữ liệu được lưu tại: $filePath')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể lấy đường dẫn file')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xuất dữ liệu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bản đồ Dữ liệu'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showDataStatistics,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSurveyData,
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Xóa tất cả dữ liệu'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.file_download, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Xuất dữ liệu'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadSurveyData,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : _surveyDataList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.map_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Chưa có dữ liệu khảo sát',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Hãy quay lại màn hình Trạm Khảo sát để thu thập dữ liệu',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadSurveyData,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _surveyDataList.length,
                        itemBuilder: (context, index) {
                          final data = _surveyDataList[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header with timestamp
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Điểm khảo sát #${index + 1}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        _formatDateTime(data.timestamp),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 12),
                                  
                                  // GPS Coordinates
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Tọa độ GPS:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          'Vĩ độ: ${data.latitude.toStringAsFixed(6)}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        Text(
                                          'Kinh độ: ${data.longitude.toStringAsFixed(6)}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 12),
                                  
                                  // Sensor Data with Icons
                                  Row(
                                    children: [
                                      // Light Intensity
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.wb_sunny,
                                              color: _getLightColor(data.lightIntensity),
                                              size: 24,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${data.lightIntensity.toStringAsFixed(1)}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: _getLightColor(data.lightIntensity),
                                              ),
                                            ),
                                            Text(
                                              'lux',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Acceleration Magnitude
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.directions_walk,
                                              color: _getAccelerationColor(data.accelerationMagnitude),
                                              size: 24,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${data.accelerationMagnitude.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: _getAccelerationColor(data.accelerationMagnitude),
                                              ),
                                            ),
                                            Text(
                                              'm/s²',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Magnetic Field Magnitude
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.explore,
                                              color: _getMagneticColor(data.magneticFieldMagnitude),
                                              size: 24,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${data.magneticFieldMagnitude.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: _getMagneticColor(data.magneticFieldMagnitude),
                                              ),
                                            ),
                                            Text(
                                              'μT',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
