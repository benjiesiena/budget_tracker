# Local LLM Model Setup

This directory contains the GGUF model file for local AI inference.

## ⚠️ Important: Large Model Files (2GB+)

Flutter's asset system cannot handle files larger than ~500MB efficiently. For models like Llama 3.2 3B (2GB+), you must place the file in the app's external storage directory manually.

## Manual Setup Instructions

### Step 1: Download the Model

1. Visit one of these Hugging Face repositories:
   - https://huggingface.co/lmstudio-community/Llama-3.2-3B-Instruct-GGUF (most popular)
   - https://huggingface.co/hugging-quants/Llama-3.2-3B-Instruct-Q4_K_M-GGUF (official quants)
   - https://huggingface.co/SanctumAI/Llama-3.2-3B-Instruct-GGUF

2. Download the Q4_K_M quantized model file (recommended balance):
   - File name: `Llama-3.2-3B-Instruct-Q4_K_M.gguf`
   - Size: ~2.0 GB
   - RAM requirement: ~5.3 GB

### Step 2: Place Model in External Storage

**For Android:**
1. Connect your device via USB
2. Navigate to: `/storage/emulated/0/Android/data/com.example.budget_tracker/files/models/`
3. Copy the model file there
4. Alternatively, use a file manager app to place it in the app's documents directory

**For iOS:**
1. Use the Files app
2. Navigate to: `On My iPhone > Budget Tracker > models/`
3. Copy the model file there

**For Desktop (Windows/Mac/Linux):**
1. Navigate to your app's documents directory
2. Create a `models` subdirectory if it doesn't exist
3. Copy the model file there

### Step 3: Update Configuration

Edit `lib/infrastructure/ai/runtime/ai_config.dart`:

```dart
static const String modelFileName = 'Llama-3.2-3B-Instruct-Q4_K_M.gguf';
static const bool useLocalLLM = true; // Enable after placing model
```

## Alternative: Smaller Models for Asset Bundling

If you want to bundle the model in the app assets (automatic setup), use a smaller model:

- **Q3_K_S** (~1.6 GB) - Still too large for assets
- **Q2_K** (~1.5 GB) - Still too large for assets
- **Phi-3 Mini (2GB)** - Better option, smaller footprint

For asset bundling, consider models under 500MB or use download-on-demand.

## Model Configuration

The model is configured in `lib/infrastructure/ai/runtime/ai_config.dart`:

```dart
class AIConfig {
  static const bool useLocalLLM = true; // Set to true after manual setup
  static const String modelFileName = 'Llama-3.2-3B-Instruct-Q4_K_M.gguf';
  static const int contextSize = 2048;
  static const int nThreads = 4;
  static const double temp = 0.7;
  static const int topK = 40;
  static const double topP = 0.9;
  static const int nGpuLayers = 0;
}
```

## Hardware Requirements

- **Minimum RAM:** 5-6 GB free
- **Recommended RAM:** 8+ GB free
- **Storage:** 2 GB for model file
- **CPU:** Multi-core processor recommended

## Troubleshooting

### Model not found error

The app will show the exact path where it expects the model file in the debug logs. Copy the model file to that location.

Example Android path from logs:
```
Expected model path: /data/user/0/com.example.budget_tracker/app_flutter/models/Llama-3.2-3B-Instruct-Q4_K_M.gguf
```

### AI doesn't respond

1. Verify model file is in the correct external storage directory
2. Check file name matches configuration exactly (case-sensitive)
3. Ensure sufficient RAM available
4. Check debug logs for initialization errors

### Out of memory errors

- Reduce `contextSize` in AIConfig (try 1024 instead of 2048)
- Reduce `nThreads` (try 2 instead of 4)
- Use a smaller model quantization

## Fallback

If the local LLM fails to initialize, the app automatically falls back to the rule-based system. To disable local LLM entirely:

```dart
static const bool useLocalLLM = false;
```