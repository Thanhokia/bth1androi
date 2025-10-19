import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import '../models/survey_data.dart';
import '../services/sensor_manager.dart';
import '../services/file_manager.dart';

class SurveyStationScreen extends StatefulWidget {
  const SurveyStationScreen({super.key});

  @override
  State<SurveyStationScreen> createState() => _SurveyStationScreenState();
}

class _SurveyStationScreenState extends State<SurveyStationScreen> {
  final SensorManager _sensorManager = SensorManager();
  final FileManager _fileManager = FileManager();
  
  bool _isInitialized = false;
  bool _isRecording = false;
  String _statusMessage = 'Đang khởi tạo cảm biến...';
  String _sensorStatus = '';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize file manager
      await _fileManager.initialize();
      
      // Request permissions
      await _requestPermissions();
      
      // Initialize sensors
      await _sensorManager.initializeSensors();
      
      // Update sensor status
      _updateSensorStatus();
      
      setState(() {
        _isInitialized = true;
        _statusMessage = 'Sẵn sàng thu thập dữ liệu';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Lỗi khởi tạo: $e';
      });
    }
  }

  Future<void> _requestPermissions() async {
    // Request location permission
    var locationStatus = await Permission.location.request();
    if (locationStatus.isDenied) {
      setState(() {
        _statusMessage = 'Cần cấp quyền truy cập vị trí để sử dụng ứng dụng';
      });
      return;
    }

    // Request location service
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _statusMessage = 'Vui lòng bật dịch vụ định vị';
      });
      return;
    }
  }

  void _updateSensorStatus() {
    final status = StringBuffer();
    
    if (_sensorManager.isLightSensorAvailable) {
      status.write('☀️ Cảm biến ánh sáng: Sẵn sàng\n');
    } else {
      status.write('☀️ Cảm biến ánh sáng: Mô phỏng\n');
    }
    
    if (_sensorManager.isAccelerometerAvailable) {
      status.write('🚶 Gia tốc kế: Sẵn sàng\n');
    } else {
      status.write('🚶 Gia tốc kế: Không khả dụng\n');
    }
    
    if (_sensorManager.isMagnetometerAvailable) {
      status.write('🧲 Từ kế: Sẵn sàng\n');
    } else {
      status.write('🧲 Từ kế: Không khả dụng\n');
    }
    
    if (_sensorManager.isGpsAvailable) {
      status.write('📍 GPS: Sẵn sàng');
    } else {
      status.write('📍 GPS: Không khả dụng');
    }
    
    setState(() {
      _sensorStatus = status.toString();
    });
  }

  Future<void> _recordData() async {
    if (!_isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ứng dụng chưa khởi tạo xong')),
      );
      return;
    }

    setState(() {
      _isRecording = true;
    });

    try {
      // Get current GPS position
      final gpsPosition = await _sensorManager.getCurrentGPSPosition();
      if (gpsPosition == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể lấy vị trí GPS')),
        );
        return;
      }

      // Get current sensor data
      final sensorData = _sensorManager.getCurrentSensorData();
      
      // Validate sensor data
      if (!_sensorManager.validateSensorData(sensorData)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dữ liệu cảm biến không hợp lệ')),
        );
        return;
      }

      // Create survey data
      final surveyData = SurveyData(
        latitude: gpsPosition.latitude,
        longitude: gpsPosition.longitude,
        lightIntensity: sensorData.lightIntensity,
        accelerationMagnitude: sensorData.accelerationMagnitude,
        magneticFieldMagnitude: sensorData.magneticFieldMagnitude,
        timestamp: DateTime.now(),
      );

      // Save to file
      final success = await _fileManager.saveSurveyData(surveyData);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dữ liệu đã được ghi thành công!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi khi ghi dữ liệu')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi ghi dữ liệu: $e')),
      );
    } finally {
      setState(() {
        _isRecording = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trạm Khảo sát'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                children: [
                  Text(
                    _statusMessage,
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_sensorStatus.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      _sensorStatus,
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // GPS Coordinates
            if (_sensorManager.gpsPosition != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tọa độ GPS',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Vĩ độ: ${_sensorManager.gpsPosition!.latitude.toStringAsFixed(6)}'),
                      Text('Kinh độ: ${_sensorManager.gpsPosition!.longitude.toStringAsFixed(6)}'),
                      Text('Độ chính xác: ${_sensorManager.gpsPosition!.accuracy.toStringAsFixed(1)}m'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Sensor Data Display
            Expanded(
              child: Column(
                children: [
                  // Light Intensity
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.wb_sunny,
                            color: _getLightColor(_sensorManager.lightIntensity),
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Cường độ Ánh sáng',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      _sensorManager.isLightSensorAvailable 
                                          ? Icons.check_circle 
                                          : Icons.sim_card,
                                      size: 16,
                                      color: _sensorManager.isLightSensorAvailable 
                                          ? Colors.green 
                                          : Colors.orange,
                                    ),
                                  ],
                                ),
                                Text(
                                  '${_sensorManager.lightIntensity.toStringAsFixed(1)} lux',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: _getLightColor(_sensorManager.lightIntensity),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Acceleration Magnitude
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.directions_walk,
                            color: _getAccelerationColor(_sensorManager.accelerationMagnitude),
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Độ "Năng động"',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      _sensorManager.isAccelerometerAvailable 
                                          ? Icons.check_circle 
                                          : Icons.error,
                                      size: 16,
                                      color: _sensorManager.isAccelerometerAvailable 
                                          ? Colors.green 
                                          : Colors.red,
                                    ),
                                  ],
                                ),
                                Text(
                                  '${_sensorManager.accelerationMagnitude.toStringAsFixed(2)} m/s²',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: _getAccelerationColor(_sensorManager.accelerationMagnitude),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Magnetic Field Magnitude
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.explore,
                            color: _getMagneticColor(_sensorManager.magneticFieldMagnitude),
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Cường độ Từ trường',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      _sensorManager.isMagnetometerAvailable 
                                          ? Icons.check_circle 
                                          : Icons.error,
                                      size: 16,
                                      color: _sensorManager.isMagnetometerAvailable 
                                          ? Colors.green 
                                          : Colors.red,
                                    ),
                                  ],
                                ),
                                Text(
                                  '${_sensorManager.magneticFieldMagnitude.toStringAsFixed(2)} μT',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: _getMagneticColor(_sensorManager.magneticFieldMagnitude),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Record Data Button
            ElevatedButton(
              onPressed: _isRecording ? null : _recordData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isRecording
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Đang ghi dữ liệu...'),
                      ],
                    )
                  : const Text(
                      'Ghi Dữ liệu tại Điểm này',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
