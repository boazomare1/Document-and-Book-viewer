import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/accessibility_provider.dart';

class TTSControls extends StatelessWidget {
  final String text;

  const TTSControls({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<AccessibilityProvider>(
      builder: (context, accessibilityProvider, child) {
        if (!accessibilityProvider.isTTSEnabled) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.volume_up, color: colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Text-to-Speech',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(accessibilityProvider.ttsController.progressPercentage).round()}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Progress bar
                LinearProgressIndicator(
                  value:
                      accessibilityProvider.ttsController.progressPercentage /
                      100,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 8),

                // Current word/sentence
                if (accessibilityProvider.ttsController.currentWord.isNotEmpty)
                  Text(
                    'Current: ${accessibilityProvider.ttsController.currentWord}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),

                const SizedBox(height: 12),

                // Control buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Previous button
                    IconButton(
                      onPressed:
                          accessibilityProvider.ttsController.isPlaying ||
                                  accessibilityProvider.ttsController.isPaused
                              ? () {
                                // TODO: Implement previous functionality
                              }
                              : null,
                      icon: Icon(
                        Icons.skip_previous,
                        color:
                            accessibilityProvider.ttsController.isPlaying ||
                                    accessibilityProvider.ttsController.isPaused
                                ? colorScheme.onSurfaceVariant
                                : colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.38,
                                ),
                      ),
                      tooltip: 'Previous word/sentence',
                    ),

                    // Play/Pause button
                    IconButton(
                      onPressed: () {
                        accessibilityProvider.toggleTTSPlayPause(text);
                      },
                      icon: Icon(
                        accessibilityProvider.ttsController.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: colorScheme.primary,
                        size: 32,
                      ),
                      tooltip:
                          accessibilityProvider.ttsController.isPlaying
                              ? 'Pause'
                              : 'Play',
                    ),

                    // Stop button
                    IconButton(
                      onPressed:
                          accessibilityProvider.ttsController.isPlaying ||
                                  accessibilityProvider.ttsController.isPaused
                              ? () {
                                accessibilityProvider.stopTTS();
                              }
                              : null,
                      icon: Icon(
                        Icons.stop,
                        color:
                            accessibilityProvider.ttsController.isPlaying ||
                                    accessibilityProvider.ttsController.isPaused
                                ? colorScheme.onSurfaceVariant
                                : colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.38,
                                ),
                      ),
                      tooltip: 'Stop',
                    ),

                    // Next button
                    IconButton(
                      onPressed:
                          accessibilityProvider.ttsController.isPlaying ||
                                  accessibilityProvider.ttsController.isPaused
                              ? () {
                                // TODO: Implement next functionality
                              }
                              : null,
                      icon: Icon(
                        Icons.skip_next,
                        color:
                            accessibilityProvider.ttsController.isPlaying ||
                                    accessibilityProvider.ttsController.isPaused
                                ? colorScheme.onSurfaceVariant
                                : colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.38,
                                ),
                      ),
                      tooltip: 'Next word/sentence',
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Speed control
                Row(
                  children: [
                    Icon(
                      Icons.speed,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Slider(
                        value: accessibilityProvider.ttsSpeed,
                        min: 0.1,
                        max: 1.0,
                        divisions: 9,
                        onChanged: (value) {
                          accessibilityProvider.setTTSSpeed(value);
                        },
                      ),
                    ),
                    Text(
                      '${accessibilityProvider.ttsSpeed.toStringAsFixed(1)}x',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),

                // Status indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(accessibilityProvider, colorScheme),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(accessibilityProvider),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getStatusTextColor(
                        accessibilityProvider,
                        colorScheme,
                      ),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(
    AccessibilityProvider provider,
    ColorScheme colorScheme,
  ) {
    if (provider.ttsController.isPlaying) {
      return colorScheme.primaryContainer;
    } else if (provider.ttsController.isPaused) {
      return colorScheme.tertiaryContainer;
    } else if (provider.ttsController.isStopped) {
      return colorScheme.surfaceContainerHighest;
    }
    return colorScheme.surfaceContainerHighest;
  }

  Color _getStatusTextColor(
    AccessibilityProvider provider,
    ColorScheme colorScheme,
  ) {
    if (provider.ttsController.isPlaying) {
      return colorScheme.onPrimaryContainer;
    } else if (provider.ttsController.isPaused) {
      return colorScheme.onTertiaryContainer;
    } else if (provider.ttsController.isStopped) {
      return colorScheme.onSurfaceVariant;
    }
    return colorScheme.onSurfaceVariant;
  }

  String _getStatusText(AccessibilityProvider provider) {
    if (provider.ttsController.isPlaying) {
      return 'Playing';
    } else if (provider.ttsController.isPaused) {
      return 'Paused';
    } else if (provider.ttsController.isStopped) {
      return 'Stopped';
    }
    return 'Ready';
  }
}
