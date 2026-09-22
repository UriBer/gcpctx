#!/usr/bin/env python3
"""Announce gcpctx releases on X as @di2ops.

The poster is the personal post-to-x skill. Pushing a new vX.Y.Z tag runs
that skill's git pre-push hook. This wrapper pins the gcpctx project and repo
for a manual summary or post.
"""

from __future__ import annotations

import os
import pwd
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def user_home() -> Path:
    return Path(pwd.getpwuid(os.getuid()).pw_dir)


def main() -> int:
    home = user_home()
    skill = home / ".cursor" / "skills" / "post-to-x" / "scripts" / "post_x.py"
    if not skill.is_file():
        print(f"error: missing {skill}", file=sys.stderr)
        return 1
    argv = [
        sys.executable,
        str(skill),
        "--project",
        "gcpctx",
        "--repo",
        "UriBer/gcpctx",
        "--workdir",
        str(ROOT),
        *sys.argv[1:],
    ]
    os.execv(sys.executable, argv)
    return 1


if __name__ == "__main__":
    sys.exit(main())
