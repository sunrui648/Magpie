# Native cursor diagnostic build based on 0.6.9

## In-place video option

Start-NativeCursorInPlace.cmd additionally keeps presentation at the original
window's physical screen rectangle when it fits on one monitor and uses Graphics
Capture. Use the regular scaling shortcut with the video window focused. The video
window can remain non-fullscreen. Effects run at the same size, including XeSS FG;
Magpie no longer expands this window to fill the monitor. 3D game mode, Desktop
Duplication and off-monitor/cross-monitor windows fall back to normal presentation.
Use same-resolution effects (the prepared CAS + XeSS FG group); explicit upscaling
effects cannot retain identical cursor coordinates. Fullscreen video still works.
The regular launcher retains the previous fullscreen presentation behavior.

新版原位置模式：退出 Magpie 托盘后，运行 Start-NativeCursorInPlace.cmd。
使用 Graphics Capture、轻度锐化加补帧 2 倍，聚焦视频窗口并按原缩放快捷键。
窗口保持原大小和位置，可使用系统光标。不会把小窗口放大铺满屏幕。
拖动/改变窗口大小时可能重启捕获；请验证点击、最小化恢复和全屏切换。

Fully exit the original Magpie from its tray before launching Start-NativeCursor.cmd.
This launcher opts into Windows cursor presentation. Launching Magpie.exe directly
uses the original cursor path. Keep the original application in its own folder.

Native cursor requires identical input/output screen rectangles, not merely equal
pixel dimensions. Use a fullscreen browser/video window with same-resolution output,
3D mode off, and no active Magpie overlay. Other geometries and overlay interactions
automatically use the original cursor path to preserve correct click coordinates.
Look for `Native system cursor active: identity screen mapping` in logs/magpie.log.
The cursor is still hidden when the video player itself requests that behavior.

This diagnostic build includes XeSS SR, XeSS FG, RTX Video and ordinary shader effects.
DLSS SR/FG/NR, FSR2/3 and AMD/NVIDIA Optical Flow are disabled in this initial test.
Use XeSS FG 2x with Optical Flow = None. Frame generation itself is unchanged.
No claim of improved mouse latency is made until a real video playback test passes.

测试方法：退出旧版托盘程序，运行 Start-NativeCursor.cmd；浏览器全屏、输出保持同分辨率，
关闭 3D 游戏模式和 Magpie 叠加面板。选 XeSS 补帧 2 倍、光流关闭。
日志出现上述 active 行后，再检查光标移动、形状切换、点击、视频自动隐藏光标和退出恢复。
本测试包仅保留 XeSS、RTX Video 和普通着色器效果；其他原生 AI 后端暂未编入。
