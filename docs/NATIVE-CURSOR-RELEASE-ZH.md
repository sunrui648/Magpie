# Magpie 0.6.9 系统光标修改（源码测试版）

这是基于 [SAOG0721/Magpie](https://github.com/SAOG0721/Magpie) 的非官方修改，保留 0.6.9 的基础代码。

## 改了什么

- 在画面与原窗口的屏幕坐标完全一致时，交给 Windows 显示系统光标，避免鼠标移动依赖 Magpie 的软件光标绘制。
- 增加可选的“原位置模式”：普通视频窗口保持原来的大小和位置，继续处理画面和补帧，不再自动铺满整个屏幕。
- 原有补帧实现没有被替换。窗口坐标不匹配、3D 游戏和 Magpie 叠加面板交互仍会使用原来的光标处理方式。

## 如何启用

从本版本源码构建后，完全退出旧 Magpie，运行 `scripts/Start-NativeCursorInPlace.cmd` 对应的启动文件。
该文件需要与编译完成的 `Magpie.exe` 放在一起。
使用 Graphics Capture，关闭 3D 游戏模式，选择同分辨率效果，例如 CAS + XeSS FG 2 倍、光流关闭。
聚焦视频窗口，然后使用程序主页显示的缩放快捷键开启效果。
日志应出现 `Native cursor in-place presentation` 和 `Native system cursor active`。

## 当前限制与验证

- 原位置模式要求窗口完整位于一个显示器内。跨屏、部分移出屏幕或真正放大画面时，不保证能使用系统光标。
- 拖动、改变窗口大小和切换全屏可能重启捕获。仍需在不同显卡、驱动、DPI、显示器和播放器上继续验证。
- 云端 Release x64 构建、光标坐标条件测试已通过；本机用户对当前视频场景反馈“基本上没有什么问题”。这不代表所有电脑都已验证。

## 下载与许可

本次公开 Release **仅提供源码**，下方的 Source code (zip / tar.gz) 是源码压缩包，不能直接双击当作软件使用。
没有上传包含可选 NVIDIA/AMD/Intel 运行库的完整安装包。
第三方组件的公开二进制再分发条件及兼容性仍需按照项目的
[第三方组件与再分发说明](https://github.com/sunrui648/Magpie/blob/native-cursor-v0.6.9/docs/THIRD_PARTY_AND_REDISTRIBUTION.md) 核对。

源码沿用项目 GPLv3 许可，保留原作者、贡献者和第三方组件的版权声明。
修改与测试方法见 `docs/NATIVE-CURSOR-TEST.md`，云端构建脚本见 `scripts/Build-NativeCursorCloud.ps1`。
