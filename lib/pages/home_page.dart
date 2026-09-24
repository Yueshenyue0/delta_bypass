import 'package:flutter/material.dart';
import 'package:flutter_miuix/miuix.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// 主页：顶部胶囊卡片显示联网状态，下方显示机型与系统信息
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Connectivity _connectivity = Connectivity();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  ConnectivityResult _conn = ConnectivityResult.none;
  String _model = '未知机型';
  String _brand = '';
  String _system = '';
  String _version = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // 联网状态
    final results = await _connectivity.checkConnectivity();
    if (results.isNotEmpty) {
      _conn = results.first;
    }

    // 机型 / 系统
    try {
      final info = await _deviceInfo.androidInfo;
      _model = info.model;
      _brand = info.brand;
      _system = 'Android ${info.version.release}';
      _version = 'API ${info.version.sdkInt}';
    } catch (_) {
      _model = '未知机型';
      _system = '未知系统';
    }

    if (!mounted) return;
    setState(() => _loading = false);
  }

  bool get _isOnline => _conn != ConnectivityResult.none;

  @override
  Widget build(BuildContext context) {
    final colors = MiuixTheme.of(context).colors;
    final ts = MiuixTheme.of(context).textStyles;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          const SizedBox(height: 12),

          // ── 顶部胶囊：联网状态 ──
          MiuixCard(
            insideMargin: const EdgeInsets.all(20),
            colors: MiuixCardColors(
              color: _isOnline ? colors.primaryVariant : colors.errorContainer,
              contentColor: _isOnline ? colors.onPrimaryVariant : colors.onErrorContainer,
            ),
            child: Row(
              children: [
                Icon(
                  _isOnline ? Icons.wifi : Icons.wifi_off,
                  size: 32,
                  color: _isOnline ? colors.onPrimaryVariant : colors.onErrorContainer,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MiuixText(
                        _isOnline ? '当前已联网' : '当前未联网',
                        style: ts.title3,
                      ),
                      const SizedBox(height: 4),
                      MiuixText(
                        _isOnline ? '网络连接正常，可正常使用' : '请检查网络连接后重试',
                        style: ts.body2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── 机型 / 系统 ──
          MiuixCard(
            insideMargin: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MiuixSmallTitle('设备信息'),
                const SizedBox(height: 12),
                _infoRow(colors, ts, '机型', '$_brand $_model'),
                const SizedBox(height: 12),
                _infoRow(colors, ts, '系统', '$_system ($_version)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(MiuixColors colors, MiuixTextStyles ts, String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: MiuixText(label, style: ts.body2),
        ),
        Expanded(
          child: MiuixText(
            _loading ? '加载中...' : value,
            style: ts.body1,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}