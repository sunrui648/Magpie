#pragma once

namespace Magpie {
template<class Rect>
constexpr bool CanUseNativeCursorInPlace(bool requested, bool game3D,
	bool graphicsCapture, const Rect& source, const Rect& monitor) noexcept {
	return requested && !game3D && graphicsCapture &&
		source.right - source.left > 1 && source.bottom - source.top > 1 &&
		source.left >= monitor.left && source.top >= monitor.top &&
		source.right <= monitor.right && source.bottom <= monitor.bottom;
}

template<class Rect>
constexpr bool CanUseNativeSystemCursor(bool requested, bool game3D, bool onOverlay,
	bool capturedOnOverlay, const Rect& source, const Rect& destination) noexcept {
	return requested && !game3D && !onOverlay && !capturedOnOverlay &&
		source.right > source.left && source.bottom > source.top &&
		source.left == destination.left && source.top == destination.top &&
		source.right == destination.right && source.bottom == destination.bottom;
}
}
