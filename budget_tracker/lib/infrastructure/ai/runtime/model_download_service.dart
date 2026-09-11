import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'ai_config.dart';

/// Service for downloading LLM models from Hugging Face
/// Handles large file downloads with progress tracking and error recovery
class ModelDownloadService {
  ModelDownloadService({
    this.onProgress,
    this.onError,
    this.onComplete,
  });

  final void Function(double progress, String message)? onProgress;
  final void Function(String error)? onError;
  final void Function(String modelPath)? onComplete;

  Dio? _dio;
  bool _isDownloading = false;
  bool _isCancelled = false;

  /// Download the configured model from Hugging Face
  Future<String?> downloadModel() async {
    if (_isDownloading) {
      debugPrint('Download already in progress');
      return null;
    }

    _isDownloading = true;
    _isCancelled = false;

    try {
      onProgress?.call(0.0, 'Starting download...');

      // Initialize Dio with timeout settings for large files
      _dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(hours: 1), // Very long timeout for 2GB file
        sendTimeout: const Duration(seconds: 30),
        // Allow redirects
        followRedirects: true,
        maxRedirects: 5,
      ));

      // Get app's documents directory for storage
      final directory = await getApplicationDocumentsDirectory();
      final modelsDir = Directory(p.join(directory.path, 'models'));
      
      if (!await modelsDir.exists()) {
        await modelsDir.create(recursive: true);
      }

      final modelPath = p.join(modelsDir.path, AIConfig.modelFileName);
      final tempPath = '$modelPath.tmp';

      // Remove temp file if it exists from previous failed download
      final tempFile = File(tempPath);
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      // Hugging Face direct download URL
      final downloadUrl = _getHuggingFaceDownloadUrl(AIConfig.modelFileName);
      debugPrint('Downloading from: $downloadUrl');

      onProgress?.call(0.1, 'Connecting to download server...');

      // Start download with progress tracking and retry logic
      int retryCount = 0;
      const maxRetries = 3;
      
      while (retryCount <= maxRetries) {
        try {
          await _downloadWithProgress(downloadUrl, tempPath);
          break; // Success, exit retry loop
        } catch (e) {
          retryCount++;
          if (retryCount > maxRetries) {
            rethrow; // Give up after max retries
          }
          
          debugPrint('Download attempt $retryCount failed: $e');
          onProgress?.call(0.0, 'Retrying... (Attempt $retryCount of $maxRetries)');
          
          // Wait before retry (exponential backoff)
          await Future.delayed(Duration(seconds: retryCount * 2));
          
          // Clean up temp file before retry
          if (await File(tempPath).exists()) {
            await File(tempPath).delete();
          }
        }
      }

      // Verify download completed successfully
      if (!await File(tempPath).exists()) {
        throw Exception('Download failed - temp file not created');
      }

      final tempFileSize = await File(tempPath).length();
      if (tempFileSize < 50 * 1024 * 1024) { // Less than 50MB (1B model is ~800MB)
        await File(tempPath).delete();
        throw Exception('Download failed - file too small (${(tempFileSize / (1024 * 1024)).toStringAsFixed(2)} MB)');
      }

      // Rename temp file to final file
      await File(tempPath).rename(modelPath);
      
      final fileSize = await File(modelPath).length();
      debugPrint('Model downloaded successfully: ${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB');
      
      onProgress?.call(1.0, 'Download complete!');
      onComplete?.call(modelPath);
      
      return modelPath;

    } catch (e) {
      debugPrint('Model download failed: $e');
      onError?.call('Download failed: $e');
      return null;
    } finally {
      _isDownloading = false;
      _dio?.close();
      _dio = null;
    }
  }

  /// Cancel the current download
  void cancelDownload() {
    if (_isDownloading && _dio != null) {
      _isCancelled = true;
      _dio?.close();
      debugPrint('Download cancelled');
    }
  }

  /// Check if model is already downloaded
  Future<bool> isModelDownloaded() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final modelPath = p.join(directory.path, 'models', AIConfig.modelFileName);
      return await File(modelPath).exists();
    } catch (e) {
      debugPrint('Error checking model status: $e');
      return false;
    }
  }

  /// Get the downloaded model path
  Future<String?> getModelPath() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final modelPath = p.join(directory.path, 'models', AIConfig.modelFileName);
      if (await File(modelPath).exists()) {
        return modelPath;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting model path: $e');
      return null;
    }
  }

  /// Delete the downloaded model to free up space
  Future<bool> deleteModel() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final modelPath = p.join(directory.path, 'models', AIConfig.modelFileName);
      final modelFile = File(modelPath);
      
      if (await modelFile.exists()) {
        await modelFile.delete();
        debugPrint('Model deleted successfully');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting model: $e');
      return false;
    }
  }

  Future<void> _downloadWithProgress(String url, String outputPath) async {
    final file = File(outputPath);
    final sink = file.openWrite();

    try {
      onProgress?.call(0.2, 'Connecting to server...');

      final response = await _dio!.get(
        url,
        onReceiveProgress: (received, total) {
          if (_isCancelled) {
            throw Exception('Download cancelled by user');
          }

          if (total != -1) {
            final progress = 0.2 + (received / total) * 0.8; // Progress from 20% to 100%
            final percent = (progress * 100).toStringAsFixed(1);
            final mbReceived = (received / (1024 * 1024)).toStringAsFixed(1);
            final mbTotal = (total / (1024 * 1024)).toStringAsFixed(1);
            
            onProgress?.call(
              progress,
              'Downloading: $mbReceived MB / $mbTotal MB ($percent%)'
            );
          } else {
            final mbReceived = (received / (1024 * 1024)).toStringAsFixed(1);
            onProgress?.call(
              0.5, // Unknown progress
              'Downloading: $mbReceived MB'
            );
          }
        },
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: const Duration(hours: 1),
        ),
      );

      if (response.statusCode == 200) {
        final bytes = response.data as List<int>;
        sink.add(bytes);
        await sink.close();
      } else {
        throw Exception('Download failed with status: ${response.statusCode}');
      }
    } catch (e) {
      await sink.close();
      // Clean up temp file on error
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (deleteError) {
          debugPrint('Error deleting temp file: $deleteError');
        }
      }
      rethrow;
    }
  }

  String _getHuggingFaceDownloadUrl(String modelFileName) {
    // Map model filenames to their Hugging Face download URLs
    // For Llama-3.2-1B models from QuantFactory (smaller, faster for mobile)
    // Note: QuantFactory uses dot (.) not dash (-) before quantization level
    if (modelFileName.contains('Llama-3.2-1B')) {
      // Using QuantFactory repository for stable downloads
      // The file naming uses Llama-3.2-1B-Instruct.Q4_K_M.gguf pattern (with dot)
      return 'https://huggingface.co/QuantFactory/Llama-3.2-1B-Instruct-GGUF/resolve/main/$modelFileName';
    }
    
    // For Llama-3.2-3B-Instruct models from lmstudio-community
    if (modelFileName.contains('Llama-3.2-3B-Instruct')) {
      return 'https://huggingface.co/lmstudio-community/Llama-3.2-3B-Instruct-GGUF/resolve/main/$modelFileName';
    }
    
    // Fallback for other models
    return 'https://huggingface.co/models/$modelFileName/resolve/main';
  }
}