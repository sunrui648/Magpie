#pragma once

namespace Magpie {
template<class Rect>
constexpr bool CanUseNativeSystemCursor(bool requested, bool game3D, bool onOverlay,
	bool capturedOnOverlay, const Rect& source, const Rect& destination) noexcept {
	return requested && !game3D && !onOverlay && !capturedOnOverlay &&
		source.right > source.left && source.bottom > source.top &&
		source.left == destination.left && source.top == destination.top &&
		source.right == destination.right && source.bottom == destination.bottom;
}
}
