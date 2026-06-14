#!/usr/bin/env python3
import sys
from pathlib import Path


# This script concatenates all files in a specified directory into a single output file.
def main():
    if len(sys.argv) < 2:
        print("Usage: python concat_files.py <directory> [output_file]")
        sys.exit(1)

    src = Path(sys.argv[1])
    out = Path(sys.argv[2]) if len(sys.argv) > 2 else Path("combined.txt")

    with out.open("w", encoding="utf-8") as f:
        for path in sorted(src.iterdir()):
            if not path.is_file() or path.resolve() == out.resolve():
                continue
            f.write(f"===== {path.name} =====\n")
            try:
                f.write(path.read_text(encoding="utf-8"))
            except (UnicodeDecodeError, PermissionError) as e:
                f.write(f"[skipped: {e}]")
            f.write("\n\n")

    print(f"Wrote {out}")


if __name__ == "__main__":
    main()
