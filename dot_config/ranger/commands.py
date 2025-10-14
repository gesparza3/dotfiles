# This is a sample commands.py.  You can add your own commands here.
from __future__ import (absolute_import, division, print_function)

import os, shlex, subprocess
from ranger.api.commands import Command

# ---------------------------------------------------------------------------
# Existing demo command (kept as-is)
# ---------------------------------------------------------------------------
class my_edit(Command):
    """:my_edit <filename>

    A sample command for demonstration purposes that opens a file in an editor.
    """
    def execute(self):
        target_filename = self.rest(1) if self.arg(1) else self.fm.thisfile.path
        self.fm.notify("Let's edit the file " + target_filename + "!")
        if not os.path.exists(target_filename):
            self.fm.notify("The given file does not exist!", bad=True)
            return
        self.fm.edit_file(target_filename)

    def tab(self, tabnum):
        return self._tab_directory_content()

# ---------------------------------------------------------------------------
# Minimal, portable fuzzy finders with FAST redraw baked in
# ---------------------------------------------------------------------------

# Shared excludes (trim/add as you like)
EXCLUDES = [
    ".git", "node_modules", ".venv", "venv",
    "dist", "build", "target",
    ".cache", ".pytest_cache", ".mypy_cache", ".tox"
]

# Snappy fzf UX (pane, cycles, auto-open on a single match)
FZF_OPTS = "--height=80% --reverse --border --cycle --select-1 --exit-0"

def _pexec(self, cmd: str):
    """Run a shell cmd via ranger's executor so UI state stays consistent."""
    proc = self.fm.execute_command(cmd, shell=True, universal_newlines=True,
                                   stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
    out = proc.stdout.read() if proc.stdout else ""
    return proc.wait(), (out or "").strip()

def _nudge_redraw(self):
    self.fm.ui.browser.need_redraw = True
    self.fm.ui.status.need_redraw = True
    self.fm.ui.redraw()

def _have(self, cmd: str) -> bool:
    return _pexec(self, f"command -v {shlex.quote(cmd)}")[0] == 0

def _fd_or_find_cmd(self, only_dirs: bool) -> str:
    """Prefer fd/fdfind; fall back to POSIX find with pruning. No symlink follow."""
    if _have(self, "fd") or _have(self, "fdfind"):
        parts = ["fd", "--hidden", "--strip-cwd-prefix"]
        if only_dirs:
            parts += ["--type", "d"]
        for pat in EXCLUDES:
            parts += ["--exclude", pat]
        return " ".join(parts)
    else:
        prune = " -o ".join([f"-path '*/{p}' -prune" for p in EXCLUDES])
        typ = "-type d" if only_dirs else ""
        return (
            "find -L . "
            + (prune + " -o " if prune else "")
            + f"-mindepth 1 {typ} -print"
        )

def _open_at_line(self, file_path: str, line: str):
    """Open file at a given line across common editors."""
    fp = shlex.quote(file_path)
    ln = str(int(line)) if line.isdigit() else "1"

    # prefer VISUAL over EDITOR
    editor = os.environ.get("VISUAL") or os.environ.get("EDITOR") or "nvim"
    base = os.path.basename(editor.split()[0]).lower()

    if base in ("nvim", "vim", "vi"):
        cmd = f"{editor} +{ln} {fp}"
    elif base == "micro":                      # micro supports +<line>
        cmd = f"{editor} +{ln} {fp}"
    elif base in ("hx", "helix"):              # helix prefers file:line
        cmd = f"{editor} {fp}:{ln}"
    elif base in ("code", "code-insiders"):    # VS Code
        cmd = f"{editor} -g {fp}:{ln}"
    elif base in ("subl", "sublime_text"):     # Sublime
        cmd = f"{editor} {fp}:{ln}"
    elif base in ("zed",):
        cmd = f"{editor} {fp}:{ln}"
    else:
        # generic fallback: try +line, then file:line
        cmd = f"{editor} +{ln} {fp}"

    self.fm.run(cmd, flags="f")

class _FastUI:
    """Temporarily lighten UI for speed, without touching defaults."""
    def __init__(self, fm): self.fm = fm
    def __enter__(self):
        s = self.fm.settings
        self._old = dict(
            linemode=getattr(self.fm.thisdir, "linemode", None),
            vcs=s.vcs_aware,
            pi=s.preview_images,
            pd=getattr(s, "preview_directories", False),
        )
        # lighten
        self.fm.execute_console("linemode filename")
        self.fm.execute_console("set preview_images false")
        if hasattr(s, "preview_directories"):
            self.fm.execute_console("set preview_directories false")
        self.fm.execute_console("set vcs_aware false")  # turn off last
        return self
    def __exit__(self, exc_type, exc, tb):
        o = self._old
        # restore non-VCS bits first
        if o["linemode"]:
            self.fm.execute_console(f"linemode {o['linemode']}")
        self.fm.execute_console(f"set preview_images {'true' if o['pi'] else 'false'}")
        if hasattr(self.fm.settings, "preview_directories"):
            self.fm.execute_console(f"set preview_directories {'true' if o['pd'] else 'false'}")
        # restore VCS *last*, and swallow errors
        try:
            self.fm.execute_console(f"set vcs_aware {'true' if o['vcs'] else 'false'}")
        except Exception:
            # leave VCS off if ranger complains; avoids “VCS exception”
            pass

class fzf_select(Command):
    """
    :fzf_select — FAST by default: temporarily disable icons/VCS/previews,
    fuzzy-pick a file or directory (recursive from CWD), then restore UI.
    """
    def execute(self):
        finder = _fd_or_find_cmd(self, only_dirs=False)
        with _FastUI(self.fm):
            code, out = _pexec(self, f"{finder} | fzf {FZF_OPTS}")
        if code != 0 or not out:
            return
        path = os.path.abspath(out)
        if os.path.isdir(path):
            self.fm.cd(path)
        else:
            self.fm.select_file(path)
        _nudge_redraw(self)

class fzf_only_dirs(Command):
    """
    :fzf_only_dirs — FAST by default for directory jumps only.
    """
    def execute(self):
        finder = _fd_or_find_cmd(self, only_dirs=True)
        with _FastUI(self.fm):
            code, out = _pexec(self, f"{finder} | fzf {FZF_OPTS}")
        if code != 0 or not out:
            return
        self.fm.cd(os.path.abspath(out))
        _nudge_redraw(self)

class rg_grep(Command):
    """
    :rg_grep [pattern] — ripgrep (vimgrep) → fzf; open in nvim at the exact line.
    """
    def execute(self):
        import re, shlex, os
        pat = self.rest(1) or "."

        code, _ = _pexec(self, "command -v rg")
        if code != 0:
            self.fm.notify("ripgrep (rg) not found in PATH", bad=True); return

        rg = ["rg", "--vimgrep", "--hidden", "--no-follow", "--color=never"]
        for p in EXCLUDES:
            rg += ["--glob", f"!{p}"]
        rg.append(pat)
        rg_cmd = " ".join(shlex.quote(x) for x in rg)

        # Keep fzf simple to make parsing reliable
        fzf_cmd = f"fzf {FZF_OPTS}"
        code, out = _pexec(self, f"{rg_cmd} | {fzf_cmd}")
        if code != 0 or not out:
            return

        m = re.match(r"^(.*?):(\d+):\d+:", out.strip())
        if not m:
            target = os.path.abspath(out.strip().split(':', 1)[0])
            if os.path.isfile(target): self.fm.select_file(target)
            else: self.fm.cd(target)
            return

        file_path = os.path.abspath(m.group(1))
        line = m.group(2)

        # Launch Neovim reliably
        self.fm.execute_console(f"shell nvim +{line} {shlex.quote(file_path)}")
