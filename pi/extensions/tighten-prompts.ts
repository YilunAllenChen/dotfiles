/**
 * Tighten Prompts - Removes the hardcoded vertical padding around user
 * message boxes that `outputPad` (a horizontal-only setting) can't touch.
 *
 * Root cause: UserMessageComponent wraps your prompt in
 *   new Box(outputPad, 1, bgFn)
 * where the "1" is a hardcoded paddingY, producing one blank
 * background-colored line above and below every prompt. There's no public
 * setting for it, so this monkey-patches the component's `rebuild()` at
 * runtime to zero out that vertical padding after it builds its Box child.
 *
 * This does NOT touch the single blank line pi inserts *between* chat
 * entries (user -> assistant -> tool etc.) for turn separation - only the
 * padding baked into the highlighted prompt box itself.
 *
 * Implementation note: this relies on pi's internal component shape
 * (Box as first child of UserMessageComponent). It's a runtime patch, not
 * a fork - if a future pi version changes that internal structure, this
 * extension just becomes a no-op (guarded, won't throw).
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { UserMessageComponent } from "@earendil-works/pi-coding-agent";
import { Box } from "@earendil-works/pi-tui";

export default function (_pi: ExtensionAPI) {
	const proto = UserMessageComponent.prototype as unknown as Record<string, (...args: unknown[]) => unknown>;
	const originalRebuild = proto.rebuild;
	if (typeof originalRebuild !== "function") return; // internal shape changed, bail out safely

	proto.rebuild = function patchedRebuild(this: { children: unknown[] }, ...args: unknown[]) {
		const result = originalRebuild.apply(this, args);
		for (const child of this.children) {
			if (child instanceof Box) {
				// paddingY is TS-private but a plain runtime property; safe to zero out.
				(child as unknown as { paddingY: number }).paddingY = 0;
			}
		}
		return result;
	};
}
