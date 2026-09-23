"""Trivial tests for the api service (no server needed)."""
from serve import payload_for


def test_health():
    assert payload_for("/health") == {"status": "ok"}


def test_root_reports_port():
    body = payload_for("/")
    assert body["service"] == "api"
    assert isinstance(body["port"], int)
