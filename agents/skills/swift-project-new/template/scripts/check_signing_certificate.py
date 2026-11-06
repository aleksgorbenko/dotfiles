#!/usr/bin/env python3
import hashlib
import pathlib
import subprocess
import sys
import tempfile


def fingerprint(certificate):
    return hashlib.sha1(certificate).hexdigest().upper()


def signing_mismatch(certificate, expected):
    actual = fingerprint(certificate)
    return None if actual == expected.upper() else f"signed with {actual}, expected {expected}"


def leaf_certificate(path):
    with tempfile.TemporaryDirectory() as directory:
        prefix = pathlib.Path(directory) / "certificate"
        subprocess.run(["codesign", "-d", f"--extract-certificates={prefix}", path], capture_output=True, check=True)
        return pathlib.Path(f"{prefix}0").read_bytes()


def main():
    path, expected = sys.argv[1], sys.argv[2]
    mismatch = signing_mismatch(leaf_certificate(path), expected)
    if mismatch:
        print(f"{path}: {mismatch}")
        sys.exit(1)
    print(f"{path}: signed with {expected}")


if __name__ == "__main__":
    main()
