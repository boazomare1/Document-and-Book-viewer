import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/accessibility_provider.dart';
import '../utils/responsive_layout.dart';

class AccessibilitySettingsScreen extends StatefulWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  State<AccessibilitySettingsScreen> createState() =>
      _AccessibilitySettingsScreenState();
}

class _AccessibilitySettingsScreenState
    extends State<AccessibilitySettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.accessibility_new,
                color: colorScheme.onSecondaryContainer,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Accessibility',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurfaceVariant),
          tooltip: 'Back',
        ),
      ),
      body: Consumer<AccessibilityProvider>(
        builder: (context, accessibilityProvider, child) {
          return SingleChildScrollView(
            padding: ResponsiveLayout.getAdaptivePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBasicSettings(
                  context,
                  theme,
                  colorScheme,
                  accessibilityProvider,
                ),
                const SizedBox(height: 32),
                _buildReflowedReaderSettings(
                  context,
                  theme,
                  colorScheme,
                  accessibilityProvider,
                ),
                const SizedBox(height: 32),
                _buildTTSSettings(
                  context,
                  theme,
                  colorScheme,
                  accessibilityProvider,
                ),
                const SizedBox(height: 32),
                _buildFocusRulerSettings(
                  context,
                  theme,
                  colorScheme,
                  accessibilityProvider,
                ),
                const SizedBox(height: 32),
                _buildKeyboardNavigationSettings(
                  context,
                  theme,
                  colorScheme,
                  accessibilityProvider,
                ),
                const SizedBox(height: 32),
                _buildResetButton(
                  context,
                  theme,
                  colorScheme,
                  accessibilityProvider,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBasicSettings(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    AccessibilityProvider provider,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Settings',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            // Font Size
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Font Size',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Text(
                  '${provider.fontSize.round()}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            Slider(
              value: provider.fontSize,
              min: 12.0,
              max: 48.0,
              divisions: 18,
              onChanged: (value) {
                provider.setFontSize(value);
              },
            ),

            const SizedBox(height: 16),

            // Line Spacing
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Line Spacing',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Text(
                  '${provider.lineSpacing.toStringAsFixed(1)}x',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            Slider(
              value: provider.lineSpacing,
              min: 1.0,
              max: 3.0,
              divisions: 20,
              onChanged: (value) {
                provider.setLineSpacing(value);
              },
            ),

            const SizedBox(height: 16),

            // Font Family
            DropdownButtonFormField<String>(
              value: provider.fontFamily,
              decoration: InputDecoration(
                labelText: 'Font Family',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items:
                  ['Arial', 'Verdana', 'Times New Roman', 'Georgia'].map((
                    font,
                  ) {
                    return DropdownMenuItem(value: font, child: Text(font));
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  provider.setFontFamily(value);
                }
              },
            ),

            const SizedBox(height: 16),

            // Color Scheme
            DropdownButtonFormField<String>(
              value: provider.colorScheme,
              decoration: InputDecoration(
                labelText: 'Color Scheme',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items:
                  ['default', 'highContrast', 'lowVision', 'colorBlind'].map((
                    scheme,
                  ) {
                    return DropdownMenuItem(
                      value: scheme,
                      child: Text(scheme.replaceAll('_', ' ').toUpperCase()),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  provider.setColorScheme(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReflowedReaderSettings(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    AccessibilityProvider provider,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reflowed Reader Mode',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            // Enable Reflowed Mode
            SwitchListTile(
              title: Text(
                'Enable Reflowed Reader Mode',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                'Display text in a more accessible format with adjustable settings',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              value: provider.isReflowedMode,
              onChanged: (value) {
                provider.setReflowedMode(value);
              },
            ),

            if (provider.isReflowedMode) ...[
              const SizedBox(height: 16),

              // Reflowed Font Size
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Reflowed Font Size',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    '${provider.reflowedFontSize.round()}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              Slider(
                value: provider.reflowedFontSize,
                min: 12.0,
                max: 48.0,
                divisions: 18,
                onChanged: (value) {
                  provider.setReflowedFontSize(value);
                },
              ),

              const SizedBox(height: 16),

              // Reflowed Line Spacing
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Reflowed Line Spacing',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    '${provider.reflowedLineSpacing.toStringAsFixed(1)}x',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              Slider(
                value: provider.reflowedLineSpacing,
                min: 1.0,
                max: 3.0,
                divisions: 20,
                onChanged: (value) {
                  provider.setReflowedLineSpacing(value);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTTSSettings(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    AccessibilityProvider provider,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Text-to-Speech',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            // Enable TTS
            SwitchListTile(
              title: Text(
                'Enable Text-to-Speech',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                'Read text aloud with synchronized highlighting',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              value: provider.isTTSEnabled,
              onChanged: (value) {
                provider.setTTSEnabled(value);
              },
            ),

            if (provider.isTTSEnabled) ...[
              const SizedBox(height: 16),

              // TTS Speed
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'TTS Speed',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    '${provider.ttsSpeed.toStringAsFixed(1)}x',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              Slider(
                value: provider.ttsSpeed,
                min: 0.1,
                max: 1.0,
                divisions: 9,
                onChanged: (value) {
                  provider.setTTSSpeed(value);
                },
              ),

              const SizedBox(height: 16),

              // Word by Word TTS
              SwitchListTile(
                title: Text(
                  'Word-by-Word TTS',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  'Highlight and speak each word individually',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                value: provider.isWordByWordTTS,
                onChanged: (value) {
                  provider.setWordByWordTTS(value);
                },
              ),

              // Sentence by Sentence TTS
              SwitchListTile(
                title: Text(
                  'Sentence-by-Sentence TTS',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  'Highlight and speak each sentence individually',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                value: provider.isSentenceBySentenceTTS,
                onChanged: (value) {
                  provider.setSentenceBySentenceTTS(value);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFocusRulerSettings(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    AccessibilityProvider provider,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Focus Ruler',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            // Enable Focus Ruler
            SwitchListTile(
              title: Text(
                'Enable Focus Ruler',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                'Show a horizontal line to help track reading position',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              value: provider.showFocusRuler,
              onChanged: (value) {
                provider.toggleFocusRuler();
              },
            ),

            if (provider.showFocusRuler) ...[
              const SizedBox(height: 16),

              // Focus Ruler Height
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Focus Ruler Height',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    '${provider.focusRulerHeight.toStringAsFixed(1)}px',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              Slider(
                value: provider.focusRulerHeight,
                min: 1.0,
                max: 10.0,
                divisions: 9,
                onChanged: (value) {
                  provider.setFocusRulerHeight(value);
                },
              ),

              const SizedBox(height: 16),

              // Focus Ruler Opacity
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Focus Ruler Opacity',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    '${(provider.focusRulerOpacity * 100).round()}%',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              Slider(
                value: provider.focusRulerOpacity,
                min: 0.1,
                max: 1.0,
                divisions: 9,
                onChanged: (value) {
                  provider.setFocusRulerOpacity(value);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildKeyboardNavigationSettings(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    AccessibilityProvider provider,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Keyboard Navigation',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            // Enable Keyboard Navigation
            SwitchListTile(
              title: Text(
                'Enable Keyboard Navigation',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                'Use keyboard shortcuts for navigation and controls',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              value: provider.isKeyboardNavigationEnabled,
              onChanged: (value) {
                provider.setKeyboardNavigationEnabled(value);
              },
            ),

            const SizedBox(height: 16),

            // Screen Reader Mode
            SwitchListTile(
              title: Text(
                'Screen Reader Mode',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                'Optimize interface for screen readers',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              value: provider.isScreenReaderMode,
              onChanged: (value) {
                provider.toggleScreenReaderMode();
              },
            ),

            const SizedBox(height: 16),

            // Enable Announcements
            SwitchListTile(
              title: Text(
                'Enable Screen Reader Announcements',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                'Announce changes and status updates',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              value: provider.enableAnnouncements,
              onChanged: (value) {
                provider.setEnableAnnouncements(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResetButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    AccessibilityProvider provider,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reset Settings',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Reset Settings'),
                        content: const Text(
                          'Are you sure you want to reset all accessibility settings to their default values?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () {
                              provider.resetToDefaults();
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Settings reset to defaults'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                );
              },
              icon: const Icon(Icons.restore),
              label: const Text('Reset to Defaults'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

