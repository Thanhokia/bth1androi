import 'dart:math';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:light_sensor/light_sensor.dart';

class SensorData {
  final double lightIntensity;
  final double accelerationMagnitude;
  final double magneticFieldMagnitude;
  final Position? gpsPosition;
  final DateTime timestamp;

  SensorData({
    required this.lightIntensity,
    required this.accelerationMagnitude,
    required this.magneticFieldMagnitude,
    this.gpsPosition,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'lightIntensity': lightIntensity,
      'accelerationMagnitude': accelerationMagnitude,
      'magneticFieldMagnitude': magneticFieldMagnitude,
      'gpsPosition': gpsPosition != null ? {
        'latitude': gpsPosition!.latitude,
        'longitude': gpsPosition!.longitude,
        'accuracy': gpsPosition!.accuracy,
        'altitude': gpsPosition!.altitude,
      } : null,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class SensorManager {
  static final SensorManager _instance = SensorManager._internal();
  factory SensorManager() => _instance;
  SensorManager._internal();

  // Sensor data streams
  Stream<double>? _lightStream;
  Stream<double>? _accelerationStream;
  Stream<double>? _magneticStream;

  // Current sensor values
  double _currentLightIntensity = 0.0;
  double _currentAccelerationMagnitude = 0.0;
  double _currentMagneticFieldMagnitude = 0.0;
  Position? _currentGpsPosition;

  // Sensor availability flags
  bool _isLightSensorAvailable = false;
  bool _isAccelerometerAvailable = false;
  bool _isMagnetometerAvailable = false;
  bool _isGpsAvailable = false;

  // Getters for current values
  double get lightIntensity => _currentLightIntensity;
  double get accelerationMagnitude => _currentAccelerationMagnitude;
  double get magneticFieldMagnitude => _currentMagneticFieldMagnitude;
  Position? get gpsPosition => _currentGpsPosition;

  // Getters for sensor availability
  bool get isLightSensorAvailable => _isLightSensorAvailable;
  bool get isAccelerometerAvailable => _isAccelerometerAvailable;
  bool get isMagnetometerAvailable => _isMagnetometerAvailable;
  bool get isGpsAvailable => _isGpsAvailable;

  /// Initialize all sensors
  Future<void> initializeSensors() async {
    await _initializeLightSensor();
    await _initializeAccelerometer();
    await _initializeMagnetometer();
    await _initializeGPS();
  }

  /// Initialize light sensor
  Future<void> _initializeLightSensor() async {
    try {
      // Check if light sensor is available
      _isLightSensorAvailable = await LightSensor.hasSensor();
      
      if (_isLightSensorAvailable) {
        _lightStream = LightSensor.luxStream().map((event) {
          _currentLightIntensity = event.toDouble();
          return event.toDouble();
        });
        
        // Start listening to light sensor
        _lightStream!.listen((lightValue) {
          _currentLightIntensity = lightValue;
        });
      } else {
        // Fallback to simulated light sensor
        _simulateLightSensor();
      }
    } catch (e) {
      print('Error initializing light sensor: $e');
      _simulateLightSensor();
    }
  }

  /// Simulate light sensor when not available
  void _simulateLightSensor() {
    _isLightSensorAvailable = false;
    // Simulate realistic light values based on time of day
    final now = DateTime.now();
    final hour = now.hour;
    
    // Simulate different light levels throughout the day
    double baseLight;
    if (hour >= 6 && hour <= 18) {
      // Daytime: 200-1000 lux
      baseLight = 200 + (hour - 6) * 50 + (DateTime.now().millisecond % 100);
    } else if (hour >= 19 && hour <= 21) {
      // Evening: 50-200 lux
      baseLight = 200 - (hour - 18) * 50 + (DateTime.now().millisecond % 50);
    } else {
      // Night: 0-50 lux
      baseLight = DateTime.now().millisecond % 50;
    }
    
    _currentLightIntensity = baseLight;
    
    // Update every second
    Future.delayed(const Duration(seconds: 1), () {
      if (_isLightSensorAvailable == false) {
        _simulateLightSensor();
      }
    });
  }

  /// Initialize accelerometer
  Future<void> _initializeAccelerometer() async {
    try {
      _isAccelerometerAvailable = true;
      
      accelerometerEventStream().listen((AccelerometerEvent event) {
        _currentAccelerationMagnitude = _calculateVectorMagnitude(
          event.x, event.y, event.z
        );
      });
    } catch (e) {
      print('Error initializing accelerometer: $e');
      _isAccelerometerAvailable = false;
    }
  }

  /// Initialize magnetometer
  Future<void> _initializeMagnetometer() async {
    try {
      _isMagnetometerAvailable = true;
      
      magnetometerEventStream().listen((MagnetometerEvent event) {
        _currentMagneticFieldMagnitude = _calculateVectorMagnitude(
          event.x, event.y, event.z
        );
      });
    } catch (e) {
      print('Error initializing magnetometer: $e');
      _isMagnetometerAvailable = false;
    }
  }

  /// Initialize GPS
  Future<void> _initializeGPS() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _isGpsAvailable = false;
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _isGpsAvailable = false;
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _isGpsAvailable = false;
        return;
      }

      _isGpsAvailable = true;
    } catch (e) {
      print('Error initializing GPS: $e');
      _isGpsAvailable = false;
    }
  }

  /// Calculate vector magnitude using proper mathematical formula
  double _calculateVectorMagnitude(double x, double y, double z) {
    return sqrt(x * x + y * y + z * z);
  }

  /// Get current GPS position
  Future<Position?> getCurrentGPSPosition() async {
    if (!_isGpsAvailable) {
      return null;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      _currentGpsPosition = position;
      return position;
    } catch (e) {
      print('Error getting GPS position: $e');
      return null;
    }
  }

  /// Get current sensor data snapshot
  SensorData getCurrentSensorData() {
    return SensorData(
      lightIntensity: _currentLightIntensity,
      accelerationMagnitude: _currentAccelerationMagnitude,
      magneticFieldMagnitude: _currentMagneticFieldMagnitude,
      gpsPosition: _currentGpsPosition,
      timestamp: DateTime.now(),
    );
  }

  /// Validate sensor data
  bool validateSensorData(SensorData data) {
    // Check for reasonable ranges
    if (data.lightIntensity < 0 || data.lightIntensity > 100000) return false;
    if (data.accelerationMagnitude < 0 || data.accelerationMagnitude > 100) return false;
    if (data.magneticFieldMagnitude < 0 || data.magneticFieldMagnitude > 1000) return false;
    
    // Check GPS if available
    if (data.gpsPosition != null) {
      if (data.gpsPosition!.latitude < -90 || data.gpsPosition!.latitude > 90) return false;
      if (data.gpsPosition!.longitude < -180 || data.gpsPosition!.longitude > 180) return false;
    }
    
    return true;
  }

  /// Dispose resources
  void dispose() {
    // Streams will be automatically disposed when the app closes
  }
}
