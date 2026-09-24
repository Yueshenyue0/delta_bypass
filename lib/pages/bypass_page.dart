import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_miuix/miuix.dart';

/// 绕过页：Delta Bypass
/// 输入忍者链接 → 校验前缀 → 分步绕过 captcha → 生成 key
class BypassPage extends StatefulWidget {
  const BypassPage({super.key});

  @override
  State<BypassPage> createState() => _BypassPageState();
}

class _BypassPageState extends State<BypassPage> {
  static const String _baseUrl = 'https://auth.platorelay.com/a?d=';

  final TextEditingController _linkController = TextEditingController();
  final List<String> _logs = [];
  final Random _random = Random();

  bool _running = false;
  bool _finished = false;
  bool _failed = false;
  String? _generatedKey;

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  bool _validateLink(String input) {
    final trimmed = input.trim();
    return trimmed.startsWith(_baseUrl) && trimmed.length > _baseUrl.length;
  }

  /// 追加一条流程日志
  void _addLog(String text) {
    setState(() => _logs.add(text));
  }

  Future<void> _runBypass() async {
    final input = _linkController.text.trim();

    // 链接校验
    if (!_validateLink(input)) {
      _showError('链接错误', '链接必须以 $_baseUrl 开头');
      return;
    }

    // 重置状态
    setState(() {
      _running = true;
      _finished = false;
      _failed = false;
      _generatedKey = null;
      _logs.clear();
    });

    // ── 第 1 步：收到链接（等待 ~1.5s）──
    _addLog('收到链接');
    await _wait(1500);

    // ── 第 2 步：正在绕过 captcha（约 8~10s）──
    _addLog('正在绕过 captcha...');
    await _wait(9000);

    // 有概率失败（约 15%）
    if (_random.nextDouble() < 0.15) {
      _addLog('绕过失败，请重试');
      setState(() {
        _failed = true;
        _running = false;
      });
      _showError('绕过失败', 'captcha 验证未通过，请重试');
      return;
    }

    // ── 第 3 步：绕过成功，正在获取 key（等待 ~1.5s）──
    _addLog('绕过成功，正在获取 key...');
    await _wait(1500);

    // ── 生成 key：FREE_ + 32 位 hex ──
    final key = _generateKey();
    _addLog('生成 key 完成');

    // 完成：输出框缩小，展示 key 卡片
    setState(() {
      _running = false;
      _finished = true;
      _generatedKey = key;
    });
  }

  String _generateKey() {
    const hexChars = '0123456789abcdef';
    final buffer = StringBuffer('FREE_');
    for (var i = 0; i < 32; i++) {
      buffer.write(hexChars[_random.nextInt(hexChars.length)]);
    }
    return buffer.toString();
  }

  Future<void> _wait(int ms) {
    return Future.delayed(Duration(milliseconds: ms));
  }

  void _showError(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _copyKey(String key) async {
    await Clipboard.setData(ClipboardData(text: key));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已复制到剪贴板'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = MiuixTheme.of(context).colors;
    final ts = MiuixTheme.of(context).textStyles;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          const SizedBox(height: 12),

          // ── 标题 ──
          Center(
            child: MiuixText(
              'Delta Bypass',
              style: ts.title1,
            ),
          ),
          const SizedBox(height: 20),

          // ── 输入框 ──
          MiuixTextField(
            controller: _linkController,
            label: '输入忍者链接',
            enabled: !_running,
            leadingIcon: const Padding(
              padding: EdgeInsets.only(left: 16, right: 8),
              child: Icon(Icons.link, size: 22),
            ),
          ),
          const SizedBox(height: 16),

          // ── 绕过按钮 ──
          MiuixButton(
            onPressed: _running ? null : _runBypass,
            child: Text(_running ? '绕过中...' : '绕过'),
          ),
          const SizedBox(height: 20),

          // ── 流程输出框 ──
          if (_logs.isNotEmpty || _finished || _failed) ...[
            _buildLogBox(colors, ts),
            const SizedBox(height: 16),
          ],

          // ── 成功：key 卡片 ──
          if (_finished && _generatedKey != null) ...[
            MiuixCard(
              insideMargin: const EdgeInsets.all(16),
              colors: MiuixCardColors(
                color: colors.primaryVariant,
                contentColor: colors.onPrimaryVariant,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MiuixText('生成成功', style: ts.title4),
                  const SizedBox(height: 8),
                  SelectableText(
                    _generatedKey!,
                    style: TextStyle(
                      color: colors.onPrimaryVariant,
                      fontFamily: 'monospace',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  MiuixButton(
                    onPressed: () => _copyKey(_generatedKey!),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.copy, size: 18),
                        SizedBox(width: 6),
                        Text('复制'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 流程日志框：运行中显示全部步骤，成功后缩小
  Widget _buildLogBox(MiuixColors colors, MiuixTextStyles ts) {
    return MiuixCard(
      insideMargin: EdgeInsets.all(_finished ? 8 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final log in _logs)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(
                    _failed && log.startsWith('绕过失败')
                        ? Icons.error_outline
                        : Icons.check_circle_outline,
                    size: 16,
                    color: _failed && log.startsWith('绕过失败')
                        ? colors.error
                        : colors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: MiuixText(log, style: ts.body2),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}