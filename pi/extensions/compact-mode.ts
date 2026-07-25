/**
 * Compact Mode - Eliminates wasted vertical whitespace in the TUI.
 *
 * Overrides built-in tools (read, bash, edit, write, grep, find, ls) with
 * tight, single-line renderCall/renderResult output and renderShell: "self"
 * so the default boxed shell (which adds background padding + blank lines)
 * is skipped entirely.
 *
 * Combine with these settings.json options for maximum effect:
 *   { "outputPad": 0, "quietStartup": true }
 *
 * Usage: just install/enable this extension. No commands needed.
 */

import type {
	BashToolDetails,
	EditToolDetails,
	ExtensionAPI,
	FindToolDetails,
	GrepToolDetails,
	LsToolDetails,
	ReadToolDetails,
} from "@earendil-works/pi-coding-agent";
import {
	createBashTool,
	createEditTool,
	createFindTool,
	createGrepTool,
	createLsTool,
	createReadTool,
	createWriteTool,
} from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";
import { homedir } from "os";

function shortenPath(path: string): string {
	const home = homedir();
	if (path.startsWith(home)) return `~${path.slice(home.length)}`;
	return path;
}

// Cache tool instances per cwd so repeated tool calls don't recreate them.
const cache = new Map<string, ReturnType<typeof buildOriginals>>();
function buildOriginals(cwd: string) {
	return {
		read: createReadTool(cwd),
		bash: createBashTool(cwd),
		edit: createEditTool(cwd),
		write: createWriteTool(cwd),
		grep: createGrepTool(cwd),
		find: createFindTool(cwd),
		ls: createLsTool(cwd),
	};
}
function originals(cwd: string) {
	let o = cache.get(cwd);
	if (!o) {
		o = buildOriginals(cwd);
		cache.set(cwd, o);
	}
	return o;
}

// Cap on lines shown when a result is expanded, keeps things scannable.
const MAX_EXPANDED_LINES = 40;

function expandedBlock(theme: import("@earendil-works/pi-coding-agent").Theme, lines: string[], color = "toolOutput" as const) {
	const shown = lines.slice(0, MAX_EXPANDED_LINES);
	const rest = lines.length - shown.length;
	let out = shown.map((l) => theme.fg(color, l)).join("\n");
	if (rest > 0) out += `\n${theme.fg("muted", `… ${rest} more lines (ctrl+o to see all)`)}`;
	return out;
}

export default function (pi: ExtensionAPI) {
	const cwd = process.cwd();
	const t = originals(cwd);

	// ---------------------------------------------------------------- read
	pi.registerTool({
		name: "read",
		label: "read",
		description: t.read.description,
		parameters: t.read.parameters,
		renderShell: "self",
		async execute(id, params, signal, onUpdate, ctx) {
			return originals(ctx.cwd).read.execute(id, params, signal, onUpdate);
		},
		renderCall(args, theme) {
			let s = `${theme.fg("toolTitle", "read")} ${theme.fg("accent", shortenPath(args.path || "…"))}`;
			if (args.offset || args.limit) {
				const start = args.offset ?? 1;
				const end = args.limit !== undefined ? start + args.limit - 1 : "";
				s += theme.fg("dim", ` :${start}${end ? `-${end}` : ""}`);
			}
			return new Text(s, 0, 0);
		},
		renderResult(result, { expanded, isPartial }, theme) {
			if (isPartial) return new Text(theme.fg("warning", "reading…"), 0, 0);
			const details = result.details as ReadToolDetails | undefined;
			const content = result.content[0];
			if (content?.type === "image") return new Text(theme.fg("success", "→ image"), 0, 0);
			if (content?.type !== "text") return new Text(theme.fg("error", "→ no content"), 0, 0);

			const lineCount = content.text.split("\n").length;
			let head = theme.fg("muted", `→ ${lineCount} lines`);
			if (details?.truncation?.truncated) head += theme.fg("warning", ` (truncated of ${details.truncation.totalLines})`);
			if (!expanded) return new Text(head, 0, 0);

			const body = expandedBlock(theme, content.text.split("\n"));
			return new Text(`${head}\n${body}`, 0, 0);
		},
	});

	// ---------------------------------------------------------------- bash
	pi.registerTool({
		name: "bash",
		label: "bash",
		description: t.bash.description,
		parameters: t.bash.parameters,
		renderShell: "self",
		async execute(id, params, signal, onUpdate, ctx) {
			return originals(ctx.cwd).bash.execute(id, params, signal, onUpdate);
		},
		renderCall(args, theme) {
			const cmd = args.command.length > 100 ? `${args.command.slice(0, 97)}…` : args.command;
			let s = `${theme.fg("toolTitle", "$")} ${theme.fg("accent", cmd)}`;
			if (args.timeout) s += theme.fg("dim", ` (${args.timeout}s)`);
			return new Text(s, 0, 0);
		},
		renderResult(result, { expanded, isPartial }, theme) {
			if (isPartial) return new Text(theme.fg("warning", "running…"), 0, 0);
			const details = result.details as BashToolDetails | undefined;
			const content = result.content[0];
			const output = content?.type === "text" ? content.text : "";
			const trimmed = output.trim();
			const lines = trimmed ? trimmed.split("\n") : [];

			const exitMatch = output.match(/exit code: (\d+)/);
			const exitCode = exitMatch ? Number.parseInt(exitMatch[1], 10) : null;

			let head = exitCode === 0 || exitCode === null ? theme.fg("success", "→ done") : theme.fg("error", `→ exit ${exitCode}`);
			if (lines.length) head += theme.fg("dim", ` (${lines.length} lines)`);
			if (details?.truncation?.truncated) head += theme.fg("warning", " [truncated]");
			if (!expanded || lines.length === 0) return new Text(head, 0, 0);

			const body = expandedBlock(theme, lines);
			return new Text(`${head}\n${body}`, 0, 0);
		},
	});

	// ---------------------------------------------------------------- edit
	pi.registerTool({
		name: "edit",
		label: "edit",
		description: t.edit.description,
		parameters: t.edit.parameters,
		renderShell: "self",
		async execute(id, params, signal, onUpdate, ctx) {
			return originals(ctx.cwd).edit.execute(id, params, signal, onUpdate);
		},
		renderCall(args, theme) {
			return new Text(`${theme.fg("toolTitle", "edit")} ${theme.fg("accent", shortenPath(args.path || "…"))}`, 0, 0);
		},
		renderResult(result, { expanded, isPartial }, theme) {
			if (isPartial) return new Text(theme.fg("warning", "editing…"), 0, 0);
			const details = result.details as EditToolDetails | undefined;
			const content = result.content[0];

			if (content?.type === "text" && /error/i.test(content.text)) {
				return new Text(theme.fg("error", `→ ${content.text.split("\n")[0]}`), 0, 0);
			}
			if (!details?.diff) return new Text(theme.fg("success", "→ applied"), 0, 0);

			const diffLines = details.diff.split("\n");
			let additions = 0;
			let removals = 0;
			for (const l of diffLines) {
				if (l.startsWith("+") && !l.startsWith("+++")) additions++;
				if (l.startsWith("-") && !l.startsWith("---")) removals++;
			}
			const head = `${theme.fg("success", `→ +${additions}`)}${theme.fg("dim", " / ")}${theme.fg("error", `-${removals}`)}`;
			if (!expanded) return new Text(head, 0, 0);

			const shown = diffLines.slice(0, MAX_EXPANDED_LINES);
			const rest = diffLines.length - shown.length;
			let body = shown
				.map((l) => {
					if (l.startsWith("+") && !l.startsWith("+++")) return theme.fg("toolDiffAdded", l);
					if (l.startsWith("-") && !l.startsWith("---")) return theme.fg("toolDiffRemoved", l);
					return theme.fg("toolDiffContext", l);
				})
				.join("\n");
			if (rest > 0) body += `\n${theme.fg("muted", `… ${rest} more diff lines`)}`;
			return new Text(`${head}\n${body}`, 0, 0);
		},
	});

	// --------------------------------------------------------------- write
	pi.registerTool({
		name: "write",
		label: "write",
		description: t.write.description,
		parameters: t.write.parameters,
		renderShell: "self",
		async execute(id, params, signal, onUpdate, ctx) {
			return originals(ctx.cwd).write.execute(id, params, signal, onUpdate);
		},
		renderCall(args, theme) {
			const lineCount = args.content ? args.content.split("\n").length : 0;
			return new Text(
				`${theme.fg("toolTitle", "write")} ${theme.fg("accent", shortenPath(args.path || "…"))}${theme.fg("dim", ` (${lineCount} lines)`)}`,
				0,
				0,
			);
		},
		renderResult(result, { isPartial }, theme) {
			if (isPartial) return new Text(theme.fg("warning", "writing…"), 0, 0);
			const content = result.content[0];
			if (content?.type === "text" && /error/i.test(content.text)) {
				return new Text(theme.fg("error", `→ ${content.text.split("\n")[0]}`), 0, 0);
			}
			return new Text(theme.fg("success", "→ written"), 0, 0);
		},
	});

	// ---------------------------------------------------------------- grep
	pi.registerTool({
		name: "grep",
		label: "grep",
		description: t.grep.description,
		parameters: t.grep.parameters,
		renderShell: "self",
		async execute(id, params, signal, onUpdate, ctx) {
			return originals(ctx.cwd).grep.execute(id, params, signal, onUpdate);
		},
		renderCall(args, theme) {
			let s = `${theme.fg("toolTitle", "grep")} ${theme.fg("accent", `/${args.pattern}/`)}`;
			s += theme.fg("dim", ` in ${shortenPath(args.path || ".")}`);
			if (args.glob) s += theme.fg("dim", ` (${args.glob})`);
			return new Text(s, 0, 0);
		},
		renderResult(result, { expanded, isPartial }, theme) {
			if (isPartial) return new Text(theme.fg("warning", "searching…"), 0, 0);
			const details = result.details as GrepToolDetails | undefined;
			const content = result.content[0];
			const text = content?.type === "text" ? content.text.trim() : "";
			const lines = text ? text.split("\n") : [];
			let head = lines.length ? theme.fg("success", `→ ${lines.length} matches`) : theme.fg("muted", "→ no matches");
			if (details?.truncation?.truncated) head += theme.fg("warning", " [truncated]");
			if (!expanded || lines.length === 0) return new Text(head, 0, 0);
			return new Text(`${head}\n${expandedBlock(theme, lines)}`, 0, 0);
		},
	});

	// ---------------------------------------------------------------- find
	pi.registerTool({
		name: "find",
		label: "find",
		description: t.find.description,
		parameters: t.find.parameters,
		renderShell: "self",
		async execute(id, params, signal, onUpdate, ctx) {
			return originals(ctx.cwd).find.execute(id, params, signal, onUpdate);
		},
		renderCall(args, theme) {
			return new Text(
				`${theme.fg("toolTitle", "find")} ${theme.fg("accent", args.pattern)}${theme.fg("dim", ` in ${shortenPath(args.path || ".")}`)}`,
				0,
				0,
			);
		},
		renderResult(result, { expanded, isPartial }, theme) {
			if (isPartial) return new Text(theme.fg("warning", "finding…"), 0, 0);
			const details = result.details as FindToolDetails | undefined;
			const content = result.content[0];
			const text = content?.type === "text" ? content.text.trim() : "";
			const lines = text ? text.split("\n") : [];
			let head = lines.length ? theme.fg("success", `→ ${lines.length} files`) : theme.fg("muted", "→ no files");
			if (details?.truncation?.truncated) head += theme.fg("warning", " [truncated]");
			if (!expanded || lines.length === 0) return new Text(head, 0, 0);
			return new Text(`${head}\n${expandedBlock(theme, lines)}`, 0, 0);
		},
	});

	// ------------------------------------------------------------------ ls
	pi.registerTool({
		name: "ls",
		label: "ls",
		description: t.ls.description,
		parameters: t.ls.parameters,
		renderShell: "self",
		async execute(id, params, signal, onUpdate, ctx) {
			return originals(ctx.cwd).ls.execute(id, params, signal, onUpdate);
		},
		renderCall(args, theme) {
			return new Text(`${theme.fg("toolTitle", "ls")} ${theme.fg("accent", shortenPath(args.path || "."))}`, 0, 0);
		},
		renderResult(result, { expanded, isPartial }, theme) {
			if (isPartial) return new Text(theme.fg("warning", "listing…"), 0, 0);
			const details = result.details as LsToolDetails | undefined;
			const content = result.content[0];
			const text = content?.type === "text" ? content.text.trim() : "";
			const lines = text ? text.split("\n") : [];
			let head = lines.length ? theme.fg("muted", `→ ${lines.length} entries`) : theme.fg("muted", "→ empty");
			if (details?.truncation?.truncated) head += theme.fg("warning", " [truncated]");
			if (!expanded || lines.length === 0) return new Text(head, 0, 0);
			return new Text(`${head}\n${expandedBlock(theme, lines)}`, 0, 0);
		},
	});
}
