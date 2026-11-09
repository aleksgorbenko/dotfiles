import hashlib
import pathlib
import sys
import unittest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))

from check_signing_certificate import fingerprint, signing_mismatch

LEAF = b"leaf certificate bytes"


class SigningCertificateTests(unittest.TestCase):
    def test_fingerprint_is_uppercase_sha1_hex(self):
        self.assertEqual(fingerprint(LEAF), hashlib.sha1(LEAF).hexdigest().upper())

    def test_matching_certificate_has_no_mismatch(self):
        self.assertIsNone(signing_mismatch(LEAF, fingerprint(LEAF).lower()))

    def test_other_certificate_is_reported(self):
        self.assertEqual(
            signing_mismatch(LEAF, "0" * 40),
            f"signed with {fingerprint(LEAF)}, expected {'0' * 40}",
        )


if __name__ == "__main__":
    unittest.main()
