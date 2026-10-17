import datetime
import pathlib
import sys
import unittest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))

from appstore_status import status_lines

PACIFIC = datetime.timezone(datetime.timedelta(hours=-7))
VERSIONS = {"data": [{"attributes": {"versionString": "1.0.0", "appStoreState": "PREPARE_FOR_SUBMISSION",
                                      "createdDate": "2026-10-12T02:13:26-07:00"}}]}
BUILDS = {
    "data": [
        {
            "attributes": {"version": "4", "processingState": "VALID", "expired": False,
                           "uploadedDate": "2026-10-16T20:21:39-07:00", "expirationDate": "2027-01-14T19:21:39-08:00"},
            "relationships": {
                "preReleaseVersion": {"data": {"type": "preReleaseVersions", "id": "v1"}},
                "betaGroups": {"data": [{"type": "betaGroups", "id": "g1"}, {"type": "betaGroups", "id": "g2"}]},
                "betaAppReviewSubmission": {"data": {"type": "betaAppReviewSubmissions", "id": "r4"}},
            },
        },
        {
            "attributes": {"version": "3", "processingState": "VALID", "expired": True,
                           "uploadedDate": "2026-10-15T20:00:00-07:00", "expirationDate": "2027-01-13T19:00:00-08:00"},
            "relationships": {
                "preReleaseVersion": {"data": {"type": "preReleaseVersions", "id": "v1"}},
                "betaGroups": {"data": []},
                "betaAppReviewSubmission": {"data": None},
            },
        },
    ],
    "included": [
        {"type": "preReleaseVersions", "id": "v1", "attributes": {"version": "1.0.0"}},
        {"type": "betaGroups", "id": "g1", "attributes": {"name": "Team"}},
        {"type": "betaGroups", "id": "g2", "attributes": {"name": "Public Beta",
                                                          "publicLinkEnabled": True,
                                                          "publicLink": "https://testflight.apple.com/join/abc"}},
        {"type": "betaAppReviewSubmissions", "id": "r4", "attributes": {"betaReviewState": "APPROVED",
                                                                          "submittedDate": "2026-10-16T20:22:43-07:00"}},
    ],
}


class StatusLinesTests(unittest.TestCase):
    def test_lists_versions_builds_review_groups_and_public_link(self):
        self.assertEqual(
            status_lines(VERSIONS, BUILDS, PACIFIC),
            [
                "App Store versions",
                "  1.0.0  PREPARE_FOR_SUBMISSION  created 2026-10-12",
                "",
                "Builds (newest first)",
                "  1.0.0 (4)  VALID  uploaded 2026-10-16 20:21  expires 2027-01-14"
                "  beta review APPROVED (submitted 2026-10-16 20:22)  groups Team, Public Beta",
                "  1.0.0 (3)  VALID, expired  uploaded 2026-10-15 20:00  expires 2027-01-13"
                "  beta review not submitted  groups none",
                "",
                "Public link: https://testflight.apple.com/join/abc (enabled)",
            ],
        )


if __name__ == "__main__":
    unittest.main()
