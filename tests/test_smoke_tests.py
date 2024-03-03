import subprocess

# Smoke test


def test_bypass_url_parser_version():
    result = subprocess.run(
        ["bypass-url-parser", "--version"], capture_output=True, text=True
    )
    assert result.returncode == 0
    assert "bypass_url_parser " in result.stdout


def test_bypass_url_parser_help():
    result = subprocess.run(
        ["bypass-url-parser", "--help"], capture_output=True, text=True
    )
    assert result.returncode == 0
    assert "Usage: bypass-url-parser"


def test_sample_usage():
    result = subprocess.run(
        ["python", "lib_sample_usage.py"], capture_output=True, text=True
    )
    assert result.returncode == 0
    assert "Bypass results for"


def test_sample_cli_usage():
    result = subprocess.run(
        "bup -u https://thinkloveshare.com/ -t 50 -m http_headers_scheme".split(" "),
        capture_output=True,
        text=True,
    )
    assert result.returncode == 0
    assert "Trying to bypass 'https://thinkloveshare.com/'" in result.stderr
    assert "Save JSON results" in result.stderr
