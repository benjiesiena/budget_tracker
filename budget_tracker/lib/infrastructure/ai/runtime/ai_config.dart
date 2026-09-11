/// Configuration for AI engine selection and model parameters.
/// 
/// Use this file to easily switch between different AI implementations
/// and configure model parameters without touching the provider setup.
class AIConfig {
  /// Whether to use the local LLM or fall back to rule-based responses
  /// Set to true to enable local LLM with automatic download
  /// Temporarily disabled due to event parsing issues with llama_cpp_dart 0.9.0
  /// Model download works perfectly, inference needs further investigation
  static const bool useLocalLLM = false;
  
  /// Model file name (must match Hugging Face filename exactly)
  /// Using smaller 1B model for faster download and better mobile performance
  /// Note: QuantFactory uses dot (.) not dash (-) before quantization
  static const String modelFileName = 'Llama-3.2-1B-Instruct.Q4_K_M.gguf';
  
  /// Context size for the model (tokens)
  static const int contextSize = 2048;
  
  /// Number of threads for model inference
  static const int nThreads = 4;
  
  /// Sampling temperature (0.0 - 1.0, higher = more creative)
  static const double temp = 0.7;
  
  /// Top-k sampling parameter
  static const int topK = 40;
  
  /// Top-p sampling parameter (0.0 - 1.0)
  static const double topP = 0.9;
  
  /// Number of GPU layers to offload (0 = CPU only, -1 = all layers)
  /// Requires GPU support and proper llama.cpp build
  static const int nGpuLayers = 0;
}