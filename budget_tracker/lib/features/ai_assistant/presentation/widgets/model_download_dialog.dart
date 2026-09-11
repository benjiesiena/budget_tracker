import 'package:flutter/material.dart';

import '../../../../infrastructure/ai/runtime/model_download_service.dart';

/// Dialog showing model download progress with cancellation option
class ModelDownloadDialog extends StatefulWidget {
  const ModelDownloadDialog({
    super.key,
    required this.onDownloadComplete,
    required this.onDownloadFailed,
  });

  final VoidCallback onDownloadComplete;
  final VoidCallback onDownloadFailed;

  @override
  State<ModelDownloadDialog> createState() => _ModelDownloadDialogState();
}

class _ModelDownloadDialogState extends State<ModelDownloadDialog> {
  double _progress = 0.0;
  String _statusMessage = 'Initializing...';
  bool _isDownloading = true;
  bool _isFailed = false;
  late ModelDownloadService _downloadService;

  @override
  void initState() {
    super.initState();
    _downloadService = ModelDownloadService(
      onProgress: (progress, message) {
        if (mounted) {
          setState(() {
            _progress = progress;
            _statusMessage = message;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isDownloading = false;
            _isFailed = true;
            _statusMessage = error;
          });
        }
      },
      onComplete: (modelPath) {
        if (mounted) {
          setState(() {
            _isDownloading = false;
            _statusMessage = 'Download complete!';
          });
          // Small delay before closing to show completion
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              widget.onDownloadComplete();
              Navigator.of(context).pop();
            }
          });
        }
      },
    );
    _startDownload();
  }

  Future<void> _startDownload() async {
    await _downloadService.downloadModel();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Download AI Model'),
      content: SizedBox(
        width: 300,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isDownloading) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(value: _progress),
                const SizedBox(height: 16),
                Text(
                  '${(_progress * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  _statusMessage,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    _downloadService.cancelDownload();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
              ] else if (_isFailed) ...[
                const SizedBox(height: 16),
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  _statusMessage,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onDownloadFailed();
                        },
                        child: const Text('Close'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _startDownload(); // Retry
                        },
                        child: const Text('Retry'),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 16),
                const Icon(
                  Icons.check_circle_outline,
                  size: 48,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                Text(
                  _statusMessage,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}