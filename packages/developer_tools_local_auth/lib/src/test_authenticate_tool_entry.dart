import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

/// A [DeveloperToolEntry] that triggers a local authentication attempt so
/// developers can test the authentication flow directly from the debug overlay.
///
/// Opens a dialog where the user can configure authentication options
/// (`biometricOnly`, `sensitiveTransaction`, `persistAcrossBackgrounding`)
/// and then trigger `authenticate()`. The result (success, failure, or
/// exception) is displayed immediately.
///
/// Useful for verifying that biometric prompts work correctly, testing
/// fallback behavior, and diagnosing authentication errors on different
/// devices.
DeveloperToolEntry testAuthenticateToolEntry({String? sectionLabel}) {
  return DeveloperToolEntry(
    title: 'Test Authentication',
    sectionLabel: sectionLabel,
    description: 'Trigger a local auth prompt and see the result',
    icon: Icons.lock_open,
    onTap: (BuildContext context) async {
      await showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) {
          return const _TestAuthenticateDialog();
        },
      );
    },
  );
}

class _TestAuthenticateDialog extends StatefulWidget {
  const _TestAuthenticateDialog();

  @override
  State<_TestAuthenticateDialog> createState() =>
      _TestAuthenticateDialogState();
}

class _TestAuthenticateDialogState extends State<_TestAuthenticateDialog> {
  bool _biometricOnly = false;
  bool _sensitiveTransaction = true;
  bool _persistAcrossBackgrounding = false;
  _AuthResult? _result;
  bool _isLoading = false;

  Future<void> _authenticate() async {
    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final auth = LocalAuthentication();
      final didAuthenticate = await auth.authenticate(
        localizedReason: 'Developer Tools: testing local authentication',
        biometricOnly: _biometricOnly,
        sensitiveTransaction: _sensitiveTransaction,
        persistAcrossBackgrounding: _persistAcrossBackgrounding,
      );
      if (mounted) {
        setState(() {
          _result = _AuthResult(
            success: didAuthenticate,
            message:
                didAuthenticate
                    ? 'Authentication succeeded'
                    : 'Authentication failed',
          );
          _isLoading = false;
        });
      }
    } on LocalAuthException catch (e) {
      if (mounted) {
        setState(() {
          _result = _AuthResult(
            success: false,
            message: 'LocalAuthException: ${e.code.name}',
            detail: e.description,
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _result = _AuthResult(
            success: false,
            message: 'Unexpected error',
            detail: e.toString(),
          );
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.lock_open, size: 24),
          SizedBox(width: 8),
          Text('Test Authentication'),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Options',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),

            // biometricOnly
            SwitchListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Biometric Only',
                style: TextStyle(fontSize: 14),
              ),
              subtitle: const Text(
                'Require biometrics, disallow pin/pattern fallback',
                style: TextStyle(fontSize: 12),
              ),
              value: _biometricOnly,
              onChanged:
                  _isLoading ? null : (v) => setState(() => _biometricOnly = v),
            ),

            // sensitiveTransaction
            SwitchListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Sensitive Transaction',
                style: TextStyle(fontSize: 14),
              ),
              subtitle: const Text(
                'Hint that this is a sensitive operation',
                style: TextStyle(fontSize: 12),
              ),
              value: _sensitiveTransaction,
              onChanged:
                  _isLoading
                      ? null
                      : (v) => setState(() => _sensitiveTransaction = v),
            ),

            // persistAcrossBackgrounding
            SwitchListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Persist Across Backgrounding',
                style: TextStyle(fontSize: 14),
              ),
              subtitle: const Text(
                'Retry auth when app returns to foreground',
                style: TextStyle(fontSize: 12),
              ),
              value: _persistAcrossBackgrounding,
              onChanged:
                  _isLoading
                      ? null
                      : (v) => setState(() => _persistAcrossBackgrounding = v),
            ),

            const SizedBox(height: 16),

            // Authenticate button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _authenticate,
                icon:
                    _isLoading
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.fingerprint),
                label: Text(_isLoading ? 'Authenticating...' : 'Authenticate'),
              ),
            ),

            // Result
            if (_result != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      _result!.success
                          ? theme.colorScheme.primaryContainer.withAlpha(50)
                          : theme.colorScheme.errorContainer.withAlpha(50),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        _result!.success
                            ? theme.colorScheme.primary.withAlpha(40)
                            : theme.colorScheme.error.withAlpha(40),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _result!.success ? Icons.check_circle : Icons.error,
                          size: 20,
                          color:
                              _result!.success
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.error,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _result!.message,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color:
                                  _result!.success
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_result!.detail != null) ...[
                      const SizedBox(height: 4),
                      SelectableText(
                        _result!.detail!,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _AuthResult {
  const _AuthResult({
    required this.success,
    required this.message,
    this.detail,
  });

  final bool success;
  final String message;
  final String? detail;
}
