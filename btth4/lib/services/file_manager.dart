import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../models/survey_data.dart';

class FileManager {
  static final FileManager _instance = FileManager._internal();
  factory FileManager() => _instance;
  FileManager._internal();

  static const String _fileName = 'schoolyard_map_data.json';
  File? _dataFile;

  /// Initialize file manager
  Future<void> initialize() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      _dataFile = File('${directory.path}/$_fileName');
    } catch (e) {
      throw Exception('Failed to initialize file manager: $e');
    }
  }

  /// Save survey data to JSON file
  Future<bool> saveSurveyData(SurveyData data) async {
    try {
      if (_dataFile == null) {
        await initialize();
      }

      List<SurveyData> existingData = await _loadAllData();
      existingData.add(data);

      return await _writeDataToFile(existingData);
    } catch (e) {
      print('Error saving survey data: $e');
      return false;
    }
  }

  /// Load all survey data from JSON file
  Future<List<SurveyData>> loadAllSurveyData() async {
    try {
      if (_dataFile == null) {
        await initialize();
      }

      return await _loadAllData();
    } catch (e) {
      print('Error loading survey data: $e');
      return [];
    }
  }

  /// Load all data from file
  Future<List<SurveyData>> _loadAllData() async {
    if (_dataFile == null || !await _dataFile!.exists()) {
      return [];
    }

    try {
      final jsonString = await _dataFile!.readAsString();
      if (jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => SurveyData.fromJson(json)).toList();
    } catch (e) {
      print('Error parsing JSON data: $e');
      return [];
    }
  }

  /// Write data to file
  Future<bool> _writeDataToFile(List<SurveyData> data) async {
    try {
      final jsonList = data.map((data) => data.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      
      await _dataFile!.writeAsString(jsonString);
      return true;
    } catch (e) {
      print('Error writing to file: $e');
      return false;
    }
  }

  /// Get file size in bytes
  Future<int> getFileSize() async {
    try {
      if (_dataFile == null || !await _dataFile!.exists()) {
        return 0;
      }
      return await _dataFile!.length();
    } catch (e) {
      print('Error getting file size: $e');
      return 0;
    }
  }

  /// Get file path
  Future<String?> getFilePath() async {
    try {
      if (_dataFile == null) {
        await initialize();
      }
      return _dataFile?.path;
    } catch (e) {
      print('Error getting file path: $e');
      return null;
    }
  }

  /// Clear all data
  Future<bool> clearAllData() async {
    try {
      if (_dataFile == null) {
        await initialize();
      }

      if (await _dataFile!.exists()) {
        await _dataFile!.delete();
      }
      return true;
    } catch (e) {
      print('Error clearing data: $e');
      return false;
    }
  }

  /// Export data to a specific file
  Future<bool> exportData(String filePath) async {
    try {
      final data = await loadAllSurveyData();
      final jsonList = data.map((data) => data.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      
      final exportFile = File(filePath);
      await exportFile.writeAsString(jsonString);
      return true;
    } catch (e) {
      print('Error exporting data: $e');
      return false;
    }
  }

  /// Import data from a specific file
  Future<bool> importData(String filePath) async {
    try {
      final importFile = File(filePath);
      if (!await importFile.exists()) {
        return false;
      }

      final jsonString = await importFile.readAsString();
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final importedData = jsonList.map((json) => SurveyData.fromJson(json)).toList();

      // Merge with existing data
      final existingData = await loadAllSurveyData();
      existingData.addAll(importedData);

      return await _writeDataToFile(existingData);
    } catch (e) {
      print('Error importing data: $e');
      return false;
    }
  }

  /// Validate JSON file integrity
  Future<bool> validateFileIntegrity() async {
    try {
      final data = await loadAllSurveyData();
      
      // Check if all data is valid
      for (final item in data) {
        if (item.latitude < -90 || item.latitude > 90) return false;
        if (item.longitude < -180 || item.longitude > 180) return false;
        if (item.lightIntensity < 0) return false;
        if (item.accelerationMagnitude < 0) return false;
        if (item.magneticFieldMagnitude < 0) return false;
      }
      
      return true;
    } catch (e) {
      print('Error validating file integrity: $e');
      return false;
    }
  }

  /// Get data statistics
  Future<Map<String, dynamic>> getDataStatistics() async {
    try {
      final data = await loadAllSurveyData();
      
      if (data.isEmpty) {
        return {
          'totalRecords': 0,
          'fileSize': await getFileSize(),
          'dateRange': null,
        };
      }

      // Calculate statistics
      final lightValues = data.map((d) => d.lightIntensity).toList();
      final accelerationValues = data.map((d) => d.accelerationMagnitude).toList();
      final magneticValues = data.map((d) => d.magneticFieldMagnitude).toList();

      return {
        'totalRecords': data.length,
        'fileSize': await getFileSize(),
        'dateRange': {
          'earliest': data.map((d) => d.timestamp).reduce((a, b) => a.isBefore(b) ? a : b),
          'latest': data.map((d) => d.timestamp).reduce((a, b) => a.isAfter(b) ? a : b),
        },
        'lightIntensity': {
          'min': lightValues.reduce((a, b) => a < b ? a : b),
          'max': lightValues.reduce((a, b) => a > b ? a : b),
          'avg': lightValues.reduce((a, b) => a + b) / lightValues.length,
        },
        'accelerationMagnitude': {
          'min': accelerationValues.reduce((a, b) => a < b ? a : b),
          'max': accelerationValues.reduce((a, b) => a > b ? a : b),
          'avg': accelerationValues.reduce((a, b) => a + b) / accelerationValues.length,
        },
        'magneticFieldMagnitude': {
          'min': magneticValues.reduce((a, b) => a < b ? a : b),
          'max': magneticValues.reduce((a, b) => a > b ? a : b),
          'avg': magneticValues.reduce((a, b) => a + b) / magneticValues.length,
        },
      };
    } catch (e) {
      print('Error getting data statistics: $e');
      return {'error': e.toString()};
    }
  }
}

