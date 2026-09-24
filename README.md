# Delta Bypass

MIUI (HyperOS) 风格的 Flutter 工具应用，基于 [flutter_miuix](https://pub.dev/packages/flutter_miuix) 组件库构建。

## 功能

- **主页**：胶囊卡片显示当前联网状态，下方显示机型与系统信息
- **绕过页（Delta Bypass）**：
  - 输入忍者链接（必须以 `https://auth.platorelay.com/a?d=` 开头）
  - 点击「绕过」后分步执行：收到链接 → 正在绕过 captcha → 绕过成功，正在获取 key → 生成 `FREE_` + 32 位 hex 的 key
  - 全程约 8~15 秒，每步 1~2 秒；有概率失败
  - 成功后输出框缩小，生成 key 卡片 + 复制按钮

## 技术栈

- Flutter 3.47 Stable（Dart 3.13）
- flutter_miuix 1.2.0（HyperOS 风格组件库）
- connectivity_plus（联网状态检测）
- device_info_plus（机型 / 系统信息）
- GitHub Actions 自动构建 APK / AAB

## 构建

推送到 GitHub 后，Actions 自动构建：

```bash
git add .
git commit -m "init"
git push
```

构建产物（Artifact）：

- `android-apk` → `build/app/outputs/flutter-apk/app-release.apk`
- `android-aab` → `build/app/outputs/bundle/release/app-release.aab`

在 GitHub Actions 页面下载即可安装。

## 本地构建（可选）

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

## 项目结构

```
lib/
├── main.dart              # 入口 + MiuixSystemTheme + 底部悬浮导航
├── pages/
│   ├── home_page.dart     # 主页：联网状态 + 设备信息
│   └── bypass_page.dart   # 绕过页：Delta Bypass 核心流程
└── (utils/ 预留)

android/                   # Android 原生骨架（Kotlin）
.github/workflows/         # GitHub Actions 自动构建
```
