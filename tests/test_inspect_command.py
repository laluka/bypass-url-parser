import shlex

from bypass_url_parser import Bypasser, Tools


def test_build_inspect_command_uses_batcat_on_linux(monkeypatch):
    monkeypatch.setattr(Tools, "IS_LINUX", True)
    monkeypatch.setattr(Tools, "IS_WINDOWS", False)

    command = Bypasser._build_inspect_command(
        "/tmp/bup results", ["first.html", "second.html"]
    )

    assert shlex.split(command) == [
        "batcat",
        "/tmp/bup results/first.html",
        "/tmp/bup results/second.html",
    ]


def test_build_inspect_command_uses_bat_on_macos(monkeypatch):
    monkeypatch.setattr(Tools, "IS_LINUX", False)
    monkeypatch.setattr(Tools, "IS_WINDOWS", False)

    command = Bypasser._build_inspect_command("/tmp/bup", ["result.html"])

    assert shlex.split(command) == ["bat", "/tmp/bup/result.html"]


def test_build_inspect_command_is_empty_without_supported_output(monkeypatch):
    monkeypatch.setattr(Tools, "IS_LINUX", False)
    monkeypatch.setattr(Tools, "IS_WINDOWS", False)
    assert Bypasser._build_inspect_command("/tmp/bup", []) == ""

    monkeypatch.setattr(Tools, "IS_WINDOWS", True)
    assert Bypasser._build_inspect_command("/tmp/bup", ["result.html"]) == ""
