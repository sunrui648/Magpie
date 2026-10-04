#include "../src/Magpie.Core/NativeCursorPolicy.h"
#include <cassert>
#include <initializer_list>

struct Rect { int left, top, right, bottom; };
int main() {
	using Magpie::CanUseNativeSystemCursor;
	const Rect full{0, 0, 1920, 1080};
	using Magpie::CanUseNativeCursorInPlace;
	const Rect browser{96, 12, 1824, 1007};
	assert(CanUseNativeCursorInPlace(true, false, true, browser, full));
	assert(CanUseNativeCursorInPlace(true, false, true, full, full));
	assert(!CanUseNativeCursorInPlace(false, false, true, browser, full));
	assert(!CanUseNativeCursorInPlace(true, true, true, browser, full));
	assert(!CanUseNativeCursorInPlace(true, false, false, browser, full));
	assert(!CanUseNativeCursorInPlace(true, false, true, Rect{-1,0,100,100}, full));
	assert(!CanUseNativeCursorInPlace(true, false, true, Rect{0,0,1921,1080}, full));
	assert(!CanUseNativeCursorInPlace(true, false, true, Rect{0,0,1,100}, full));
	assert(!CanUseNativeCursorInPlace(true, false, true, Rect{0,0,0,0}, full));
	const Rect otherMonitor{-1920,0,0,1080};
	assert(CanUseNativeCursorInPlace(true, false, true, Rect{-1800,100,-100,1000}, otherMonitor));
	assert(CanUseNativeSystemCursor(true, false, false, false, full, full));
	const Rect secondMonitor{-1920, 0, 0, 1080};
	assert(CanUseNativeSystemCursor(true, false, false, false, secondMonitor, secondMonitor));
	assert(!CanUseNativeSystemCursor(false, false, false, false, full, full));
	assert(!CanUseNativeSystemCursor(true, true, false, false, full, full));
	assert(!CanUseNativeSystemCursor(true, false, true, false, full, full));
	assert(!CanUseNativeSystemCursor(true, false, false, true, full, full));
	// Even a one-pixel translation invalidates native click coordinates.
	for (const Rect changed : {Rect{1, 0, 1921, 1080}, Rect{0, 1, 1920, 1081},
		Rect{0, 0, 1921, 1080}, Rect{0, 0, 1920, 1081}})
		assert(!CanUseNativeSystemCursor(true, false, false, false, full, changed));
	assert(!CanUseNativeSystemCursor(true, false, false, false, Rect{0, 0, 0, 0}, Rect{0, 0, 0, 0}));
}
