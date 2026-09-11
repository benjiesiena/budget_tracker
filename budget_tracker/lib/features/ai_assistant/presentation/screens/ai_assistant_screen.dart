import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/presentation/providers/app_providers.dart';
import '../../domain/ai_orchestrator.dart';
import '../providers/ai_chat_provider.dart';
import '../widgets/ai_message_bubble.dart';
import '../widgets/ai_quick_action.dart';
import '../widgets/model_download_dialog.dart';

/// AI Assistant chat screen (PRD wireframe 9.9). Talks only to
/// [AIChatNotifier] -> [AIOrchestrator]; it never touches a repository or
/// tool directly, so this screen doesn't need to change when the rule-based
/// engine is swapped for the real on-device model.
class AIAssistantScreen extends ConsumerStatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  ConsumerState<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends ConsumerState<AIAssistantScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _checkModelStatus();
  }

  Future<void> _checkModelStatus() async {
    final downloadService = ref.read(modelDownloadServiceProvider);
    final isDownloaded = await downloadService.isModelDownloaded();
    
    if (mounted && !isDownloaded) {
      _showDownloadDialog();
    }
  }

  void _showDownloadDialog() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ModelDownloadDialog(
        onDownloadComplete: () {
          // Model downloaded successfully, reload AI engine
          ref.invalidate(aiEngineProvider);
        },
        onDownloadFailed: () {
          // Fallback to rule-based system
          ref.invalidate(aiEngineProvider);
        },
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send([String? text]) async {
    final message = (text ?? _inputController.text).trim();
    if (message.isEmpty) return;
    _inputController.clear();
    await ref.read(aiChatProvider.notifier).sendMessage(message);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(aiChatProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('AI Assistant')),
      body: Column(
        children: [
          Expanded(
            child: chatState.messages.isEmpty
                ? _EmptyChatGreeting(onQuickAction: _send)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: chatState.messages.length + (chatState.isResponding ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= chatState.messages.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }
                      return AIMessageBubble(message: chatState.messages[index]);
                    },
                  ),
          ),
          const Divider(height: 1),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      decoration: const InputDecoration(hintText: 'Ask a question...'),
                      onSubmitted: (_) => _send(),
                      textInputAction: TextInputAction.send,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  IconButton.filled(
                    onPressed: chatState.isResponding ? null : () => _send(),
                    icon: const Icon(Icons.arrow_upward),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChatGreeting extends StatelessWidget {
  final ValueChanged<String> onQuickAction;

  const _EmptyChatGreeting({required this.onQuickAction});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: context.appColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Good day 👋', style: AppTypography.sectionHeading),
              const SizedBox(height: 4),
              Text(
                'How can I help with your money today?',
                style: AppTypography.body.copyWith(color: context.appColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final prompt in AIOrchestrator.quickActions)
              AIQuickAction(label: _shortLabel(prompt), onTap: () => onQuickAction(prompt)),
          ],
        ),
      ],
    );
  }

  String _shortLabel(String prompt) {
    if (prompt.contains('afford')) return 'Can I afford something?';
    if (prompt.contains('spend the most')) return 'Analyze my spending';
    if (prompt.contains('budget')) return 'Review my budget';
    if (prompt.contains('save more')) return 'Help me save';
    return prompt;
  }
}
