# Local AI Setup Instructions

## Overview

Your budget tracker now supports local LLM inference using llama.cpp with Llama 3.2 3B model. This provides more natural and intelligent responses for budget tracking advice.

## ⚠️ Important: Large Model Files

**The 2GB model file cannot be bundled in Flutter assets.** You must manually place it in the app's external storage directory.

## Quick Setup for Android

### 1. Download the Model

1. Visit: https://huggingface.co/lmstudio-community/Llama-3.2-3B-Instruct-GGUF
2. Download: `Llama-3.2-3B-Instruct-Q4_K_M.gguf` (~2.0 GB)

### 2. Place Model in App Storage

**Option A: Using ADB (Recommended for developers)**
```bash
# Enable USB debugging on your device
# Then run:
adb push Llama-3.2-3B-Instruct-Q4_K_M.gguf /storage/emulated/0/Android/data/com.example.budget_tracker/files/models/
```

**Option B: Using File Manager**
1. Install a file manager app on your Android device
2. Navigate to: `/storage/emulated/0/Android/data/com.example.budget_tracker/files/`
3. Create a `models` folder if it doesn't exist
4. Copy the downloaded model file there

### 3. Enable Local AI

Edit `lib/infrastructure/ai/runtime/ai_config.dart`:

```dart
static const bool useLocalLLM = true; // Already enabled
static const String modelFileName = 'Llama-3.2-3B-Instruct-Q4_K_M.gguf'; // Already correct
```

### 4. Run the App

```bash
flutter run
```

## Setup for iOS

### 1. Download the Model

Same as above.

### 2. Place Model in App Storage

1. Use the Files app on your iOS device
2. Navigate to: `On My iPhone > Budget Tracker > models/`
3. Copy the model file there

### 3. Enable and Run

Same as Android steps 3-4.

## Setup for Desktop (Windows/Mac/Linux)

### 1. Download the Model

Same as above.

### 2. Place Model in App Storage

1. Find your app's documents directory:
   - **Windows**: `C:\Users\[YourName]\Documents\`
   - **Mac**: `~/Documents/`
   - **Linux**: `~/Documents/`

2. Create a `models` subdirectory
3. Copy the model file there

### 3. Enable and Run

Same as Android steps 3-4.

## Hardware Requirements

- **RAM:** 5-6 GB free minimum
- **Storage:** 2 GB for model file
- **CPU:** Multi-core recommended

## Configuration Options

Edit `lib/infrastructure/ai/runtime/ai_config.dart` to customize:

- `useLocalLLM`: Toggle between local LLM and rule-based responses
- `modelFileName`: Change model file if using different quantization
- `contextSize`: Adjust context window (default: 2048 tokens)
- `nThreads`: Number of CPU threads (default: 4)
- `temp`: Response creativity (0.0-1.0, default: 0.7)
- `nGpuLayers`: GPU acceleration (0 = CPU only, requires GPU support)

## Alternative Model Quantizations

If you have limited RAM:

- **Q3_K_S** (~1.6 GB) - Good balance
- **Q2_K** (~1.5 GB) - Smallest size

If you want better quality:

- **Q5_K_M** (~2.4 GB) - Better quality
- **Q6_K** (~2.7 GB) - Very good quality

## Troubleshooting

### Model doesn't load

1. Check the debug logs for the exact expected path
2. Verify model file is in that location
3. Check file name matches exactly (case-sensitive)
4. Ensure sufficient RAM available

### Out of memory errors

- Reduce `contextSize` in config (try 1024 instead of 2048)
- Reduce `nThreads` (try 2 instead of 4)
- Use a smaller model quantization

### Slow responses

- Reduce `contextSize` in config
- Reduce `nThreads` if CPU is overloaded
- Try smaller quantization (Q3_K_S)

### Fallback to rule-based

If local LLM fails, the app automatically falls back to rule-based responses. Set `useLocalLLM = false` in config to disable local LLM entirely.

## Testing

After setup, try these questions in the AI assistant:

- "Can I afford to spend ₱2,000 this weekend?"
- "Where did I spend the most this month?"
- "How am I doing on my budget?"
- "How can I save more?"

## Architecture

The implementation uses:

- **llama_cpp_dart**: Dart binding for llama.cpp
- **LocalLLMAIEngine**: Implements AIEngine interface
- **AIConfig**: Centralized configuration
- **External storage**: For large model files (2GB+)
- **Automatic fallback**: Rule-based system if LLM fails

Files modified:
- `pubspec.yaml` - Added llama_cpp_dart dependency
- `lib/infrastructure/ai/runtime/local_llm_ai_engine.dart` - New LLM engine
- `lib/infrastructure/ai/runtime/ai_config.dart` - Configuration
- `lib/shared/presentation/providers/app_providers.dart` - Provider setup
- `assets/models/README.md` - Model setup instructions