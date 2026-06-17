#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: Copyright (c) 2026 Ainekko, Co.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""
junit2html — cocotb-aware JUnit XML reporter and merger.

Commands
--------
  Merge multiple XML files into one GitLab-CI-compatible XML:
    junit2html --merge <out.xml> <in1.xml> [in2.xml ...]

  HTML dashboard with suite overview + parameter matrix as hero:
    junit2html --report-matrix <out.html> <in.xml>

  Full detailed HTML report:
    junit2html <in.xml> [out.html]

  Print a text summary + parameter matrix to stdout:
    junit2html --summary-matrix <in.xml> [--max-failures N]
"""

import sys
import re
import html as html_mod
import json
from pathlib import Path
from xml.etree import ElementTree as ET
from datetime import datetime
from collections import defaultdict, OrderedDict


# ══════════════════════════════════════════════════════════════════════════════
#  HELPERS
# ══════════════════════════════════════════════════════════════════════════════

_GENERIC_SUITE_NAMES = {"all", "results", "", "suite"}

def _suite_name_from_source(xml_name, source_path):
    """
    If the suite's XML name is generic ("all", "results", etc.),
    derive a meaningful name from the source filename.
    Strip trailing _results suffix and leading underscores.
    """
    if xml_name.lower() in _GENERIC_SUITE_NAMES:
        stem = Path(source_path).stem          # e.g. "test_qspi_results"
        name = re.sub(r'_results$', '', stem)  # "test_qspi"
        name = name.lstrip('_')                # strip leading _
        return name if name else stem
    return xml_name


def _dedup_names(names):
    """Return list of names with duplicates disambiguated by appending _2, _3 …"""
    seen = {}
    result = []
    for n in names:
        if n not in seen:
            seen[n] = 0
            result.append(n)
        else:
            seen[n] += 1
            result.append("{}_{}".format(n, seen[n] + 1))
    return result


def _test_base_name(test_name):
    """
    Extract the function name prefix before the first /key=val segment.
    e.g. "test_rwds_mask_write/latency=8/pin=1" → "test_rwds_mask_write"
         "default_test/mode=0/latency=8"         → "default_test"
         "test_register_read_write"               → None  (not parametrized)
    """
    m = re.match(r'^([^/]+)/\w+=', test_name)
    return m.group(1) if m else None


def _is_parametrized(testcases):
    """True if the majority of test names contain key=value parameter patterns."""
    if not testcases:
        return False
    count = sum(1 for t in testcases if re.search(r'\w+=\w+', t["name"]))
    return count / len(testcases) > 0.5


def _discover_param_axes(tests):
    """
    Determine the best axis ordering for the matrix.

    Strategy:
    1. If tests have multiple distinct base function names, inject "_fn" as the
       first axis — it becomes the row key, giving one row per test function.
    2. Among real param keys, prefer keys that appear in EVERY test (high coverage)
       — these make clean column headers with no "?" holes.
    3. Within equal coverage, preserve the order keys appear in test names.
    4. Sparse keys (appear in only some tests) go last as extra/grouping axes.
    """
    if not tests:
        return []

    # Count how many tests each param key appears in
    coverage = defaultdict(int)   # key → count of tests that have it
    order_seen = OrderedDict()    # key → first-appearance index in any test name
    appearance_idx = 0
    for t in tests:
        for m in re.finditer(r'(\w+)=([^/\s]+)', t["name"]):
            k = m.group(1)
            coverage[k] += 1
            if k not in order_seen:
                order_seen[k] = appearance_idx
                appearance_idx += 1

    n = len(tests)

    # Check for multiple distinct base function names
    base_names = set()
    for t in tests:
        bn = _test_base_name(t["name"])
        if bn:
            base_names.add(bn)
    has_multiple_fns = len(base_names) > 1

    # Sort keys: full-coverage keys first (in name-appearance order),
    # then partial-coverage keys (in name-appearance order)
    full_keys    = [k for k in order_seen if coverage[k] == n]
    partial_keys = [k for k in order_seen if coverage[k] <  n]
    full_keys.sort(   key=lambda k: order_seen[k])
    partial_keys.sort(key=lambda k: order_seen[k])

    axes = []
    if has_multiple_fns:
        axes.append("_fn")   # synthetic axis: test function base name
    axes.extend(full_keys)
    axes.extend(partial_keys)
    return axes


def _sorted_param_vals(tests, key):
    """Return sorted unique values of param `key`, with '?' always last."""
    if key == "_fn":
        vals = sorted(set(_test_base_name(t["name"]) or "?" for t in tests))
        return vals
    raw = set(t["params"].get(key, "?") for t in tests)
    # Sort: numeric values numerically, strings alphabetically, "?" always last
    def sort_key(x):
        if x == "?":
            return (2, 0, "")
        if x.isdigit():
            return (0, int(x), "")
        try:
            return (1, 0, x)
        except Exception:
            return (1, 0, str(x))
    return sorted(raw, key=sort_key)


def _group_by_extra_params(tests, extra_keys):
    """Group tests by the extra (tertiary+) param keys for sub-matrix splitting."""
    if not extra_keys:
        return OrderedDict([("", tests)])
    groups = defaultdict(list)
    for t in tests:
        parts = []
        for k in extra_keys:
            if k == "_fn":
                v = _test_base_name(t["name"]) or "?"
            else:
                v = t["params"].get(k, "?")
            parts.append("{}={}".format(k, v))
        label = " · ".join(parts)
        groups[label].append(t)

    def sort_key(label):
        # Sort "?" groups last; otherwise numeric-first
        if "=?" in label:
            return (1, label)
        nums = re.findall(r'\d+', label)
        return (0, [int(n) for n in nums]) if nums else (0, [label])

    return OrderedDict(sorted(groups.items(), key=lambda kv: sort_key(kv[0])))


# ══════════════════════════════════════════════════════════════════════════════
#  XML PARSING
# ══════════════════════════════════════════════════════════════════════════════

def _parse_suite(suite_elem, source_path=""):
    properties = {}
    for prop in (suite_elem.findall("properties/property")
                 + suite_elem.findall("property")):
        properties[prop.get("name", "")] = prop.get("value", "")

    testcases = []
    for tc in suite_elem.findall("testcase"):
        failure = tc.find("failure")
        error   = tc.find("error")
        skipped = tc.find("skipped")

        if failure is not None:
            status    = "FAIL"
            fail_type = failure.get("error_type") or failure.get("type", "")
            fail_msg  = failure.get("error_msg")  or failure.get("message", "")
            fail_text = (failure.text or "").strip()
        elif error is not None:
            status    = "ERROR"
            fail_type = error.get("type", "")
            fail_msg  = error.get("message", "")
            fail_text = (error.text or "").strip()
        elif skipped is not None:
            status    = "SKIP"
            fail_type = ""
            fail_msg  = skipped.get("message", "")
            fail_text = ""
        else:
            status    = "PASS"
            fail_type = fail_msg = fail_text = ""

        name = tc.get("name", "")
        params = OrderedDict()
        for m in re.finditer(r'(\w+)=([^/\s]+)', name):
            params[m.group(1)] = m.group(2)

        testcases.append({
            "name":        name,
            "classname":   tc.get("classname", ""),
            "file":        tc.get("file", ""),
            "lineno":      tc.get("lineno", ""),
            "time":        float(tc.get("time", 0) or 0),
            "sim_time_ns": float(tc.get("sim_time_ns", 0) or 0),
            "ratio_time":  float(tc.get("ratio_time", 0) or 0),
            "status":      status,
            "fail_type":   fail_type,
            "fail_msg":    fail_msg,
            "fail_text":   fail_text,
            "params":      params,
        })

    xml_name = suite_elem.get("name", "")
    display_name = _suite_name_from_source(xml_name, source_path)
    passed  = sum(1 for t in testcases if t["status"] == "PASS")
    failed  = sum(1 for t in testcases if t["status"] == "FAIL")
    errors  = sum(1 for t in testcases if t["status"] == "ERROR")
    skipped = sum(1 for t in testcases if t["status"] == "SKIP")

    return {
        "xml_name":     xml_name,
        "name":         display_name,
        "package":      suite_elem.get("package", ""),
        "source":       source_path,
        "properties":   properties,
        "testcases":    testcases,
        "total":        len(testcases),
        "passed":       passed,
        "failed":       failed,
        "errors":       errors,
        "skipped":      skipped,
        "total_time":   sum(t["time"] for t in testcases),
        "parametrized": _is_parametrized(testcases),
    }


def parse_junit_xml(path):
    tree = ET.parse(path)
    root = tree.getroot()
    suite_elems = root.findall("testsuite") if root.tag == "testsuites" else [root]
    suites = [_parse_suite(s, path) for s in suite_elems]

    # Deduplicate suite names within this file
    raw_names = [s["name"] for s in suites]
    deduped   = _dedup_names(raw_names)
    for s, n in zip(suites, deduped):
        s["name"] = n

    report_name = root.get("name", Path(path).stem)
    if report_name.lower() in _GENERIC_SUITE_NAMES:
        report_name = Path(path).stem

    return {
        "name":      report_name,
        "source":    path,
        "generated": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "suites":    suites,
    }


def all_tests(report):
    out = []
    for s in report["suites"]:
        for t in s["testcases"]:
            out.append(dict(t, _suite=s["name"]))
    return out


# ══════════════════════════════════════════════════════════════════════════════
#  MERGE  →  GitLab-CI-compatible XML
# ══════════════════════════════════════════════════════════════════════════════

def cmd_merge(output_xml, input_paths):
    """
    Merge N JUnit XML files → single <testsuites> compatible with GitLab CI.

    Suite naming: generic XML suite names ("all", "results", etc.) are replaced
    with the source filename stem so every suite has a meaningful unique name.
    Failures use standard GitLab-required type= and message= attributes.
    """
    all_reports = []
    for p in input_paths:
        print("  Reading {}".format(p))
        all_reports.append(parse_junit_xml(p))

    root = ET.Element("testsuites")
    total_tests = total_fail = total_err = total_skip = 0
    total_time  = 0.0

    for report in all_reports:
        for suite in report["suites"]:
            se = ET.SubElement(root, "testsuite",
                name     = suite["name"],
                tests    = str(suite["total"]),
                failures = str(suite["failed"]),
                errors   = str(suite["errors"]),
                skipped  = str(suite["skipped"]),
                time     = "{:.6f}".format(suite["total_time"]),
            )
            if suite["source"]:
                se.set("source", suite["source"])

            if suite["properties"]:
                props_el = ET.SubElement(se, "properties")
                for k, v in suite["properties"].items():
                    ET.SubElement(props_el, "property", name=k, value=v)

            for tc in suite["testcases"]:
                attrs = dict(
                    name      = tc["name"],
                    classname = tc["classname"],
                    time      = "{:.6f}".format(tc["time"]),
                )
                if tc["file"]:    attrs["file"]   = tc["file"]
                if tc["lineno"]:  attrs["lineno"] = tc["lineno"]
                if tc["sim_time_ns"]:
                    attrs["sim_time_ns"] = "{:.3f}".format(tc["sim_time_ns"])
                if tc["ratio_time"]:
                    attrs["ratio_time"]  = "{:.3f}".format(tc["ratio_time"])

                tc_el = ET.SubElement(se, "testcase", **attrs)

                if tc["status"] == "FAIL":
                    full = tc["fail_msg"] or tc["fail_text"]
                    fe = ET.SubElement(tc_el, "failure",
                        type    = tc["fail_type"] or "AssertionError",
                        message = (tc["fail_msg"] or "")[:512],
                    )
                    fe.text = full
                elif tc["status"] == "ERROR":
                    ee = ET.SubElement(tc_el, "error",
                        type    = tc["fail_type"] or "Error",
                        message = (tc["fail_msg"] or "")[:512],
                    )
                    ee.text = tc["fail_text"] or tc["fail_msg"]
                elif tc["status"] == "SKIP":
                    ET.SubElement(tc_el, "skipped",
                        message = tc["fail_msg"] or "")

            total_tests += suite["total"]
            total_fail  += suite["failed"]
            total_err   += suite["errors"]
            total_skip  += suite["skipped"]
            total_time  += suite["total_time"]

    root.set("tests",    str(total_tests))
    root.set("failures", str(total_fail))
    root.set("errors",   str(total_err))
    root.set("skipped",  str(total_skip))
    root.set("time",     "{:.6f}".format(total_time))

    try:
        ET.indent(ET.ElementTree(root), space="  ")
    except AttributeError:
        _indent_xml(root)

    Path(output_xml).parent.mkdir(parents=True, exist_ok=True)
    ET.ElementTree(root).write(output_xml, encoding="utf-8", xml_declaration=True)

    print("Merged {} file(s) → {}".format(len(input_paths), output_xml))
    print("  {} tests  |  {} failures  |  {} skipped".format(
        total_tests, total_fail + total_err, total_skip))


def _indent_xml(elem, level=0):
    pad = "\n" + "  " * level
    if len(elem):
        if not elem.text or not elem.text.strip():
            elem.text = pad + "  "
        for child in elem:
            _indent_xml(child, level + 1)
        if not child.tail or not child.tail.strip():
            child.tail = pad
    if level and (not elem.tail or not elem.tail.strip()):
        elem.tail = pad


# ══════════════════════════════════════════════════════════════════════════════
#  SUMMARY MATRIX  →  terminal
# ══════════════════════════════════════════════════════════════════════════════

def _ansi(code, text):
    return "\033[{}m{}\033[0m".format(code, text) if sys.stdout.isatty() else text

def _green(s):  return _ansi("32;1", s)
def _red(s):    return _ansi("31;1", s)
def _yellow(s): return _ansi("33",   s)
def _dim(s):    return _ansi("2",    s)
def _bold(s):   return _ansi("1",    s)


def cmd_summary_matrix(input_xml, max_failures=20):
    report = parse_junit_xml(input_xml)
    tests  = all_tests(report)

    total    = len(tests)
    passed   = sum(1 for t in tests if t["status"] == "PASS")
    failed   = sum(1 for t in tests if t["status"] in ("FAIL", "ERROR"))
    skipped  = sum(1 for t in tests if t["status"] == "SKIP")
    total_t  = sum(t["time"] for t in tests)
    pass_pct = (passed / total * 100) if total else 0.0

    print()
    print(_bold("  {}".format(report["name"])))
    print(_dim("  {}  ·  {}".format(input_xml, report["generated"])))
    print()

    verdict = _green("✓ PASS") if failed == 0 else _red("✗ FAIL")
    print("  {}   {} tests  {} passed  {} failed  {} skipped  ({:.1f}%)  {}".format(
        verdict, _bold(str(total)),
        _green(str(passed)),
        _red(str(failed))     if failed  else _dim("0"),
        _yellow(str(skipped)) if skipped else _dim("0"),
        pass_pct,
        _dim("{:.2f}s".format(total_t)),
    ))
    print()

    # Per-suite summary
    suites = report["suites"]
    if len(suites) > 1:
        print(_bold("  Suites:"))
        for s in suites:
            mark = _green("✓") if s["failed"] + s["errors"] == 0 else _red("✗")
            print("  {}  {:<30}  {}/{} passed".format(
                mark, s["name"], s["passed"], s["total"]))
        print()

    # Matrix for parametrized suites
    for s in suites:
        if s["parametrized"]:
            tc = s["testcases"]
            print(_bold("  Matrix: {}".format(s["name"])))
            _print_param_matrix(tc)

    # Sim stats
    if any(t["sim_time_ns"] > 0 for t in tests):
        _print_sim_stats(tests)

    # Failures
    failures = [t for t in tests if t["status"] in ("FAIL", "ERROR")]
    if failures:
        shown = failures[:max_failures]
        print(_bold("  Failures ({} total, showing {}):".format(
            len(failures), len(shown))))
        print()
        for t in shown:
            print("  {} {}".format(_red("✗"), _bold(t["name"])))
            suite_tag = "  [{}]".format(t.get("_suite", ""))
            print(_dim("  " + suite_tag))
            if t["fail_type"]:
                print("    {}".format(_yellow(t["fail_type"])))
            msg = t["fail_msg"] or t["fail_text"]
            if msg:
                first = msg.split("\n")[0].strip()
                if first:
                    print("    {}".format(_dim(first[:120])))
            print()
        if len(failures) > max_failures:
            print(_dim("  … and {} more (use --max-failures to show more)".format(
                len(failures) - max_failures)))
            print()
    else:
        print(_green("  🎉  All tests passed!"))
        print()


def _print_param_matrix(testcases):
    axes     = _discover_param_axes(testcases)
    if len(axes) < 2:
        return
    row_key, col_key = axes[0], axes[1]
    extra_keys = axes[2:]
    row_vals = _sorted_param_vals(testcases, row_key)
    col_vals = _sorted_param_vals(testcases, col_key)
    combos   = _group_by_extra_params(testcases, extra_keys)

    row_label_prefix = "test" if row_key == "_fn" else row_key

    for combo_label, combo_tests in combos.items():
        display_label = re.sub(r'_fn=[^ ·]+\s*·?\s*', '', combo_label).strip(" ·")
        if display_label:
            print(_dim("    {}".format(display_label)))

        col_w       = max((len(str(v)) for v in col_vals), default=1)
        row_label_w = max((len("{}={}".format(row_label_prefix, v))
                           for v in row_vals), default=8)

        header = " " * (row_label_w + 2)
        for cv in col_vals:
            header += "  {:>{}}".format(str(cv), col_w)
        print("    " + _dim(header))

        idx = defaultdict(list)
        for t in combo_tests:
            key = (_get_axis_val(t, row_key), _get_axis_val(t, col_key))
            idx[key].append(t)

        for rv in row_vals:
            if row_key == "_fn":
                label = "{}={}".format(row_label_prefix, rv)
            else:
                label = "{}={}".format(row_key, rv)
            row_str  = "  {:<{}}  ".format(label, row_label_w)
            for cv in col_vals:
                ts = idx.get((rv, cv), [])
                if not ts:
                    cell = _dim("·" * col_w)
                elif any(t["status"] not in ("PASS","SKIP") for t in ts):
                    cell = _red("▓" * col_w)
                else:
                    cell = _green("█" * col_w)
                row_str += "  {}".format(cell)
            print("    " + row_str)
        print()


def _print_sim_stats(tests):
    by_mode = defaultdict(list)
    for t in tests:
        by_mode[t["params"].get("mode", t.get("_suite", "?"))].append(t)

    print(_bold("  Simulation stats:"))
    print(_dim("  {:<30}  {:>10}  {:>10}  {:>12}  {:>10}".format(
        "suite/mode", "pass/total", "avg wall", "avg sim ns", "avg ratio")))
    for mode in sorted(by_mode.keys(), key=lambda x: (int(x),) if x.isdigit() else (float('inf'), x)):
        ts  = by_mode[mode]
        n   = len(ts)
        ok  = sum(1 for t in ts if t["status"] == "PASS")
        aw  = sum(t["time"] for t in ts) / n * 1000
        asn = sum(t["sim_time_ns"] for t in ts) / n
        ar  = sum(t["ratio_time"]  for t in ts) / n
        stat = _green("{}/{}".format(ok, n)) if ok == n else _red("{}/{}".format(ok, n))
        print("  {:<30}  {:>10}  {:>8.2f}ms  {:>12.1f}  {:>10,.0f}x".format(
            mode, stat, aw, asn, ar))
    print()


# ══════════════════════════════════════════════════════════════════════════════
#  HTML  —  shared generation
# ══════════════════════════════════════════════════════════════════════════════

def cmd_html(input_xml, output_html, matrix_first=False):
    print("Parsing {}…".format(input_xml))
    report = parse_junit_xml(input_xml)
    tests  = all_tests(report)

    total   = len(tests)
    failed  = sum(1 for t in tests if t["status"] in ("FAIL", "ERROR"))
    print("  {} suites  |  {} tests  |  {} failures".format(
        len(report["suites"]), total, failed))

    content = _build_html(report, matrix_first)
    Path(output_html).parent.mkdir(parents=True, exist_ok=True)
    with open(output_html, "w", encoding="utf-8") as f:
        f.write(content)
    print("Report written to {}".format(output_html))


def _build_html(report, matrix_first=False):
    he     = html_mod.escape
    suites = report["suites"]
    tests  = all_tests(report)

    total    = len(tests)
    passed   = sum(1 for t in tests if t["status"] == "PASS")
    failed   = sum(1 for t in tests if t["status"] in ("FAIL", "ERROR"))
    skipped  = sum(1 for t in tests if t["status"] == "SKIP")
    n_suites = len(suites)
    total_t  = sum(t["time"] for t in tests)
    pass_pct = (passed / total * 100) if total else 0.0
    fail_pct = 100 - pass_pct

    status_class = "pass" if failed == 0 else "fail"
    verdict_txt  = ("✓ ALL PASS" if failed == 0
                    else "✗ {} FAILURE{}".format(failed, "S" if failed != 1 else ""))

    # Build per-suite HTML sections
    suite_sections = []
    for i, suite in enumerate(suites):
        suite_sections.append(_build_suite_section(suite, i, matrix_first))

    suite_grid_html = _build_suite_grid(suites)
    sections_html   = "\n".join(suite_sections)

    # Serialise ALL tests for the JS detail table
    tests_json = json.dumps([{
        "name":      t["name"],
        "suite":     t.get("_suite", ""),
        "classname": t["classname"],
        "status":    t["status"],
        "time":      round(t["time"], 4),
        "sim_ns":    round(t["sim_time_ns"], 2),
        "ratio":     round(t["ratio_time"], 0),
        "fail_type": t["fail_type"],
        "fail_msg":  t["fail_msg"],
        "params":    dict(t["params"]),
    } for t in tests], separators=(",", ":"))

    return """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{title} — Test Report</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@300;400;500;600&family=IBM+Plex+Sans:wght@300;400;500;600&display=swap" rel="stylesheet">
<style>{css}</style>
</head>
<body>

<header>
  <div class="header-inner">
    <div class="header-title">
      <span class="header-label">TEST REPORT</span>
      <h1>{title}</h1>
      <span class="header-date">Generated {generated}</span>
    </div>
    <div class="header-verdict {status_class}">{verdict}</div>
  </div>
</header>

<main>

  <!-- ── Summary strip ─────────────────────────────── -->
  <section class="summary-grid">
    <div class="card card-total"><div class="card-value">{n_suites}</div><div class="card-label">SUITES</div></div>
    <div class="card card-total"><div class="card-value">{total}</div><div class="card-label">TESTS</div></div>
    <div class="card card-pass"><div class="card-value">{passed}</div><div class="card-label">PASSED</div></div>
    <div class="card card-fail"><div class="card-value">{failed}</div><div class="card-label">FAILED</div></div>
    <div class="card card-skip"><div class="card-value">{skipped}</div><div class="card-label">SKIPPED</div></div>
    <div class="card card-time"><div class="card-value">{total_t:.1f}<span class="card-unit">s</span></div><div class="card-label">WALL TIME</div></div>
  </section>
  <div class="progress-bar-wrap">
    <div class="progress-bar-pass" style="width:{pass_pct:.2f}%"></div>
    <div class="progress-bar-fail" style="width:{fail_pct:.2f}%"></div>
  </div>

  <!-- ── Suite overview grid ───────────────────────── -->
  {suite_grid}

  <!-- ── Per-suite sections ────────────────────────── -->
  {sections}

  <!-- ── Full test table (collapsed by default) ────── -->
  <section class="section" id="all-tests-section">
    <h2 class="section-title toggle-trigger" onclick="toggleSection('all-tests-body')">
      All Tests
      <span class="count-badge">{total}</span>
      <span class="section-toggle" id="all-tests-body-toggle">▼</span>
    </h2>
    <div id="all-tests-body" style="display:none">
      <div class="table-controls">
        <input type="text" id="search" placeholder="Filter tests…" oninput="filterTable()">
        <div class="filter-pills">
          <button class="pill active" onclick="setFilter('ALL',this)">All</button>
          <button class="pill" onclick="setFilter('PASS',this)">Pass</button>
          <button class="pill" onclick="setFilter('FAIL',this)">Fail</button>
        </div>
      </div>
      <div class="table-wrap">
        <table id="tests-table">
          <thead><tr>
            <th onclick="sortTable(0)" class="sortable">#</th>
            <th onclick="sortTable(1)" class="sortable">Suite</th>
            <th onclick="sortTable(2)" class="sortable">Test Name</th>
            <th onclick="sortTable(3)" class="sortable">Status</th>
            <th onclick="sortTable(4)" class="sortable">Wall (s)</th>
            <th onclick="sortTable(5)" class="sortable">Sim (ns)</th>
            <th>Failure</th>
          </tr></thead>
          <tbody id="table-body"></tbody>
        </table>
      </div>
      <div id="table-footer" class="table-footer"></div>
    </div>
  </section>

</main>

<footer><span>junit2html · {generated}</span></footer>

<script>
const TESTS = {tests_json};
let _filter='ALL', _search='', _sortCol=0, _sortDir=1;

function esc(s){{return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');}}
function badge(s){{
  const m={{PASS:'badge-pass',FAIL:'badge-fail',SKIP:'badge-skip',ERROR:'badge-error'}};
  return '<span class="badge '+(m[s]||'badge-error')+'">'+s+'</span>';
}}
function renderTable(){{
  const body=document.getElementById('table-body');
  const footer=document.getElementById('table-footer');
  const q=_search.toLowerCase();
  let rows=TESTS.map((t,i)=>Object.assign({{}},t,{{_i:i+1}}));
  if(_filter!=='ALL') rows=rows.filter(t=>t.status===_filter);
  if(q) rows=rows.filter(t=>
    t.name.toLowerCase().includes(q)||
    (t.suite||'').toLowerCase().includes(q)||
    (t.fail_msg||'').toLowerCase().includes(q));
  rows.sort((a,b)=>{{
    const cols=[a._i,a.suite,a.name,a.status,a.time,a.sim_ns];
    const colb=[b._i,b.suite,b.name,b.status,b.time,b.sim_ns];
    const av=cols[_sortCol], bv=colb[_sortCol];
    return av<bv?-_sortDir:av>bv?_sortDir:0;
  }});
  body.innerHTML=rows.map(t=>{{
    const fc=t.fail_type
      ?'<span class="err-type">'+esc(t.fail_type)+'</span> '
       +'<span class="err-msg">'+esc((t.fail_msg||'').substring(0,100))
       +((t.fail_msg||'').length>100?'…':'')+'</span>':'';
    return '<tr class="'+(t.status==='FAIL'||t.status==='ERROR'?'row-fail':'')+'">'+
      '<td class="mono dim">'+t._i+'</td>'+
      '<td class="mono suite-cell">'+esc(t.suite||'')+'</td>'+
      '<td class="mono name-cell">'+esc(t.name)+'</td>'+
      '<td>'+badge(t.status)+'</td>'+
      '<td class="mono num">'+t.time.toFixed(3)+'</td>'+
      '<td class="mono num">'+t.sim_ns.toFixed(0)+'</td>'+
      '<td class="fail-cell">'+fc+'</td></tr>';
  }}).join('');
  footer.textContent='Showing '+rows.length+' of '+TESTS.length+' tests';
}}
function filterTable(){{_search=document.getElementById('search').value;renderTable();}}
function setFilter(v,btn){{
  _filter=v;
  document.querySelectorAll('.pill').forEach(p=>p.classList.remove('active'));
  btn.classList.add('active');
  renderTable();
}}
function sortTable(c){{
  if(_sortCol===c)_sortDir=-_sortDir; else{{_sortCol=c;_sortDir=1;}}
  renderTable();
}}
function toggleDetail(id){{
  var el=document.getElementById(id);
  if(!el) return;
  el.style.display=el.style.display==='none'?'block':'none';
}}
function toggleSection(id){{
  var el=document.getElementById(id);
  var tog=document.getElementById(id+'-toggle');
  if(!el) return;
  var vis=el.style.display==='none';
  el.style.display=vis?'block':'none';
  if(tog) tog.textContent=vis?'▲':'▼';
}}
renderTable();
</script>
</body>
</html>""".format(
        title        = he(report["name"]),
        generated    = he(report["generated"]),
        status_class = status_class,
        verdict      = verdict_txt,
        n_suites     = n_suites,
        total        = total,
        passed       = passed,
        failed       = failed,
        skipped      = skipped,
        total_t      = total_t,
        pass_pct     = pass_pct,
        fail_pct     = fail_pct,
        suite_grid   = suite_grid_html,
        sections     = sections_html,
        tests_json   = tests_json,
        css          = _get_css(),
    )


# ── Suite overview grid ───────────────────────────────────────────────────────

def _build_suite_grid(suites):
    cards = []
    for i, s in enumerate(suites):
        total  = s["total"]
        passed = s["passed"]
        failed = s["failed"] + s["errors"]
        pct    = (passed / total * 100) if total else 0

        status_cls  = "suite-card-pass" if failed == 0 else "suite-card-fail"
        verdict_ico = "✓" if failed == 0 else "✗"
        verdict_cls = "suite-ico-pass" if failed == 0 else "suite-ico-fail"
        type_tag    = "sweep" if s["parametrized"] else "functional"

        # Short failure excerpt for failing suites
        fail_excerpt = ""
        if failed:
            first_fail = next(
                (t for t in s["testcases"] if t["status"] in ("FAIL","ERROR")), None)
            if first_fail and first_fail["fail_msg"]:
                msg = first_fail["fail_msg"].split("\n")[0].strip()
                fail_excerpt = '<div class="suite-card-excerpt">{}</div>'.format(
                    html_mod.escape(msg[:80] + ("…" if len(msg) > 80 else "")))

        cards.append(
            '<a class="suite-card {sc}" href="#suite-{i}">'
            '  <div class="suite-card-top">'
            '    <span class="suite-card-name">{name}</span>'
            '    <span class="suite-ico {vc}">{ico}</span>'
            '  </div>'
            '  <div class="suite-card-bar-wrap">'
            '    <div class="suite-card-bar-pass" style="width:{pct:.1f}%"></div>'
            '    <div class="suite-card-bar-fail" style="width:{fail_pct:.1f}%"></div>'
            '  </div>'
            '  <div class="suite-card-stats">'
            '    <span class="suite-pass-count">{passed}/{total}</span>'
            '    <span class="suite-type-tag">{tt}</span>'
            '  </div>'
            '  {excerpt}'
            '</a>'.format(
                sc       = status_cls,
                i        = i,
                name     = html_mod.escape(s["name"]),
                vc       = verdict_cls,
                ico      = verdict_ico,
                pct      = pct,
                fail_pct = 100 - pct,
                passed   = passed,
                total    = total,
                tt       = type_tag,
                excerpt  = fail_excerpt,
            )
        )

    return """<section class="suite-grid-section">
  <h2 class="section-title">Suites <span class="count-badge">{n}</span></h2>
  <div class="suite-grid">{cards}</div>
</section>""".format(n=len(suites), cards="\n".join(cards))


# ── Per-suite section ─────────────────────────────────────────────────────────

def _build_suite_section(suite, idx, matrix_first):
    he      = html_mod.escape
    total   = suite["total"]
    passed  = suite["passed"]
    failed  = suite["failed"] + suite["errors"]
    skipped = suite["skipped"]
    total_t = suite["total_time"]
    pass_pct = (passed / total * 100) if total else 0.0
    status_cls = "pass" if failed == 0 else "fail"

    # Properties row
    props_html = ""
    if suite["properties"]:
        prop_items = " ".join(
            '<span class="prop-item"><span class="prop-key">{}</span>'
            '<span class="prop-val">{}</span></span>'.format(
                he(k), he(v))
            for k, v in suite["properties"].items()
        )
        props_html = '<div class="suite-props">{}</div>'.format(prop_items)

    # Body: matrix or functional test list
    if suite["parametrized"]:
        body_html = _build_matrix_html(suite["testcases"])
    else:
        body_html = _build_functional_table(suite["testcases"], idx)

    # Failures (inline, for functional suites only — matrix suites have tooltips)
    failures_html = ""
    if failed and not suite["parametrized"]:
        failures_html = _build_inline_failures(suite["testcases"], idx)

    if matrix_first:
        inner = body_html + failures_html
    else:
        inner = failures_html + body_html

    return """<section class="suite-section" id="suite-{idx}">
  <div class="suite-section-header">
    <div class="suite-section-title">
      <span class="suite-section-verdict {sc}">{verdict_ico}</span>
      <span class="suite-section-name">{name}</span>
      <span class="suite-mini-stats">{passed}/{total} passed · {total_t:.1f}s</span>
    </div>
    <a class="back-link" href="#top">↑ top</a>
  </div>
  {props}
  <div class="suite-section-bar-wrap">
    <div class="suite-section-bar-pass" style="width:{ppc:.1f}%"></div>
    <div class="suite-section-bar-fail" style="width:{fpc:.1f}%"></div>
  </div>
  {inner}
</section>""".format(
        idx        = idx,
        sc         = status_cls,
        verdict_ico = "✓" if failed == 0 else "✗",
        name    = he(suite["name"]),
        passed  = passed,
        total   = total,
        total_t = total_t,
        props   = props_html,
        ppc     = pass_pct,
        fpc     = 100 - pass_pct,
        inner   = inner,
    ).replace("PLACEHOLDER_NEVER_USED", "")


# ── Parametrized matrix ───────────────────────────────────────────────────────

def _get_axis_val(t, key):
    """Get the value of an axis key for a test, handling the synthetic _fn key."""
    if key == "_fn":
        return _test_base_name(t["name"]) or "?"
    return t["params"].get(key, "?")


def _build_matrix_html(testcases):
    axes = _discover_param_axes(testcases)
    if len(axes) < 2:
        return _build_functional_table(testcases, 0)

    row_key    = axes[0]
    col_key    = axes[1]
    extra_keys = axes[2:]

    row_vals = _sorted_param_vals(testcases, row_key)
    col_vals = _sorted_param_vals(testcases, col_key)
    combos   = _group_by_extra_params(testcases, extra_keys)

    # Friendly axis labels — strip the "_fn" internal name
    row_label = "test" if row_key == "_fn" else row_key
    col_label = col_key

    col_headers = "".join(
        "<th>{}</th>".format(html_mod.escape(str(v))) for v in col_vals)
    col_label_row = "<tr><th class='ax-label'>{}</th>{}</tr>".format(
        html_mod.escape(col_label), col_headers)

    matrices = []
    for combo_label, combo_tests in combos.items():
        # Index: (row_val, col_val) → list of tests (multiple if not a clean sweep)
        idx = defaultdict(list)
        for t in combo_tests:
            key = (_get_axis_val(t, row_key), _get_axis_val(t, col_key))
            idx[key].append(t)

        row_htmls = []
        for rv in row_vals:
            cells = []
            for cv in col_vals:
                ts = idx.get((rv, cv), [])
                if not ts:
                    cells.append("<td class='cell-empty'></td>")
                else:
                    # Aggregate: fail if any fail, else pass
                    any_fail = any(t["status"] not in ("PASS", "SKIP") for t in ts)
                    if not any_fail:
                        ratio = ts[0]["ratio_time"]
                        wall  = ts[0]["time"]
                        tip = "ratio={:,.0f}x  wall={:.3f}s".format(ratio, wall)
                        if len(ts) > 1:
                            tip = "{} tests · ".format(len(ts)) + tip
                        cells.append(
                            "<td class='cell-pass' title='{}'></td>".format(tip))
                    else:
                        fail_t = next(t for t in ts if t["status"] not in ("PASS","SKIP"))
                        ft = html_mod.escape(fail_t["fail_type"])
                        fm = html_mod.escape(fail_t["fail_msg"][:100])
                        n_str = "" if len(ts) == 1 else "{} tests · ".format(len(ts))
                        cells.append(
                            "<td class='cell-fail' title='{}{}:{}'></td>".format(
                                n_str, ft, fm))

            # Row label: for _fn show just the function name, else key=val
            if row_key == "_fn":
                row_lbl = html_mod.escape(str(rv))
            else:
                row_lbl = "{}={}".format(html_mod.escape(row_label),
                                         html_mod.escape(str(rv)))
            row_htmls.append(
                "<tr><th class='row-label'>{}</th>{}</tr>".format(
                    row_lbl, "".join(cells)))

        # Strip the "_fn=" prefix from combo labels for readability
        display_label = re.sub(r'_fn=[^ ·]+\s*·?\s*', '', combo_label).strip(" ·")

        label_html = (
            "<div class='matrix-group-label'>{}</div>".format(
                html_mod.escape(display_label))
            if display_label else "")

        matrices.append(
            "<div class='matrix-block'>"
            "{label}"
            "<table class='matrix-table'>"
            "<thead>{col_label_row}</thead>"
            "<tbody>{rows}</tbody>"
            "</table></div>".format(
                label         = label_html,
                col_label_row = col_label_row,
                rows          = "".join(row_htmls)))

    total  = len(testcases)
    passed = sum(1 for t in testcases if t["status"] == "PASS")
    failed = total - passed

    return """<div class="matrix-section">
  <div class="matrix-legend">
    <span class="legend-item"><span class="legend-swatch pass-swatch"></span>Pass ({passed})</span>
    <span class="legend-item"><span class="legend-swatch fail-swatch"></span>Fail ({failed})</span>
    <span class="legend-tip">Hover cells for details</span>
  </div>
  <div class="matrix-scroll">
    <div class="matrix-wrap">{matrices}</div>
  </div>
</div>""".format(
        passed   = passed,
        failed   = failed,
        matrices = "".join(matrices))


# ── Functional test list ──────────────────────────────────────────────────────

def _build_functional_table(testcases, suite_idx):
    rows = []
    for i, t in enumerate(testcases):
        status_cls = ""
        if t["status"] in ("FAIL", "ERROR"):
            status_cls = "row-fail"
        elif t["status"] == "SKIP":
            status_cls = "row-skip"

        # Failure summary (one-liner inline)
        fail_inline = ""
        if t["status"] in ("FAIL", "ERROR") and t["fail_msg"]:
            first_line = t["fail_msg"].split("\n")[0].strip()
            fail_inline = '<div class="inline-fail">{}</div>'.format(
                html_mod.escape(first_line[:120] + ("…" if len(first_line) > 120 else "")))

        badge_cls = {"PASS":"badge-pass","FAIL":"badge-fail",
                     "SKIP":"badge-skip","ERROR":"badge-error"}.get(t["status"], "badge-error")

        sim_cell = ""
        if t["sim_time_ns"] > 0:
            sim_cell = "{:.0f}".format(t["sim_time_ns"])

        rows.append(
            "<tr class='{sc}'>"
            "<td class='mono dim ft-num'>{n}</td>"
            "<td class='ft-name'><span class='mono'>{name}</span>{fail}</td>"
            "<td><span class='badge {bc}'>{st}</span></td>"
            "<td class='mono num'>{wall:.3f}</td>"
            "<td class='mono num dim'>{sim}</td>"
            "</tr>".format(
                sc   = status_cls,
                n    = i + 1,
                name = html_mod.escape(t["name"]),
                fail = fail_inline,
                bc   = badge_cls,
                st   = t["status"],
                wall = t["time"],
                sim  = sim_cell,
            ))

    return """<div class="ft-table-wrap">
  <table class="ft-table">
    <thead><tr>
      <th>#</th>
      <th>Test</th>
      <th>Status</th>
      <th>Wall (s)</th>
      <th>Sim (ns)</th>
    </tr></thead>
    <tbody>{rows}</tbody>
  </table>
</div>""".format(rows="".join(rows))


# ── Inline failure cards ──────────────────────────────────────────────────────

def _build_inline_failures(testcases, suite_idx):
    failures = [t for t in testcases if t["status"] in ("FAIL","ERROR")]
    if not failures:
        return ""
    items = []
    for j, t in enumerate(failures):
        did      = "fd-{}-{}".format(suite_idx, j)
        msg_html = _format_assertion(t["fail_msg"])
        items.append(
            "<div class='failure-card'>"
            "<div class='failure-header' onclick=\"toggleDetail('{did}')\">"
            "<span class='failure-name mono'>{name}</span>"
            "<span class='failure-type'>{ftype}</span>"
            "<span class='failure-toggle'>▼</span>"
            "</div>"
            "<div class='failure-meta'>"
            "<span class='mono dim'>sim={sim:.0f}ns</span>"
            "<span class='mono dim'>wall={wall:.3f}s</span>"
            "</div>"
            "<div id='{did}' class='failure-detail' style='display:none'>{msg}</div>"
            "</div>".format(
                did   = did,
                name  = html_mod.escape(t["name"]),
                ftype = html_mod.escape(t["fail_type"]),
                sim   = t["sim_time_ns"],
                wall  = t["time"],
                msg   = msg_html,
            ))
    return "<div class='failures-list'>{}</div>".format("".join(items))


def _format_assertion(msg):
    if not msg:
        return ""
    raw = (msg.replace("&#10;", "\n").replace("&lt;","<")
              .replace("&gt;",">").replace("&amp;","&").replace("&#34;",'"'))
    parts = []
    for line in raw.split("\n"):
        esc = html_mod.escape(line)
        if line.strip().startswith("assert "):
            parts.append("<span class='assert-main'>{}</span>".format(esc))
        elif re.search(r'\+\s+where', line):
            parts.append("<span class='assert-where'>{}</span>".format(esc))
        elif re.match(r"^\s*\+", line):
            parts.append("<span class='assert-detail'>{}</span>".format(esc))
        else:
            parts.append("<span class='assert-line'>{}</span>".format(esc))
    return "<pre class='assert-block'>" + "\n".join(parts) + "</pre>"


# ══════════════════════════════════════════════════════════════════════════════
#  CSS
# ══════════════════════════════════════════════════════════════════════════════

def _get_css():
    return """
:root {
  --bg:        #0b0d12;
  --bg2:       #12151e;
  --bg3:       #181c28;
  --bg4:       #1f2435;
  --border:    #272e45;
  --text:      #c4cde8;
  --text-dim:  #4e5878;
  --text-mid:  #7b88b0;
  --pass:      #00e5a0;
  --pass-dim:  #002e22;
  --pass-bg:   #001510;
  --fail:      #ff4060;
  --fail-dim:  #35080f;
  --fail-bg:   #180307;
  --skip:      #f0c040;
  --accent:    #38bdf8;
  --accent2:   #818cf8;
  --mono: 'IBM Plex Mono','Courier New',monospace;
  --sans: 'IBM Plex Sans',system-ui,sans-serif;
  --radius: 6px;
}
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0;}
html{scroll-behavior:smooth;}
body{background:var(--bg);color:var(--text);font-family:var(--sans);font-size:14px;line-height:1.6;}
a{color:inherit;text-decoration:none;}

/* ── Header ── */
header{background:var(--bg2);border-bottom:1px solid var(--border);position:sticky;top:0;z-index:200;}
.header-inner{max-width:1500px;margin:0 auto;padding:14px 32px;display:flex;align-items:center;justify-content:space-between;gap:24px;}
.header-label{font-family:var(--mono);font-size:9px;letter-spacing:.25em;color:var(--accent);display:block;margin-bottom:2px;text-transform:uppercase;}
h1{font-size:18px;font-weight:600;color:#fff;letter-spacing:-.02em;}
.header-date{font-family:var(--mono);font-size:10px;color:var(--text-dim);display:block;margin-top:2px;}
.header-verdict{font-family:var(--mono);font-size:13px;font-weight:600;letter-spacing:.1em;padding:7px 18px;border-radius:var(--radius);white-space:nowrap;}
.header-verdict.pass{color:var(--pass);background:var(--pass-bg);border:1px solid var(--pass-dim);}
.header-verdict.fail{color:var(--fail);background:var(--fail-bg);border:1px solid var(--fail-dim);}

/* ── Main ── */
main{max-width:1500px;margin:0 auto;padding:28px 32px 80px;}

/* ── Summary grid ── */
.summary-grid{display:grid;grid-template-columns:repeat(6,1fr);gap:10px;margin-bottom:10px;}
@media(max-width:900px){.summary-grid{grid-template-columns:repeat(3,1fr);}}
.card{background:var(--bg2);border:1px solid var(--border);border-radius:var(--radius);padding:14px 16px;text-align:center;}
.card-value{font-family:var(--mono);font-size:26px;font-weight:600;line-height:1;margin-bottom:4px;}
.card-unit{font-size:13px;font-weight:300;opacity:.5;}
.card-label{font-size:9px;letter-spacing:.18em;color:var(--text-dim);font-weight:600;text-transform:uppercase;}
.card-total .card-value{color:var(--text);}
.card-pass  .card-value{color:var(--pass);}
.card-fail  .card-value{color:var(--fail);}
.card-skip  .card-value{color:var(--skip);}
.card-time  .card-value{color:var(--accent2);}

/* ── Progress bar ── */
.progress-bar-wrap{height:3px;display:flex;background:var(--bg4);border-radius:2px;overflow:hidden;margin-bottom:36px;}
.progress-bar-pass{background:var(--pass);}
.progress-bar-fail{background:var(--fail);}

/* ── Section titles ── */
.section{margin-bottom:36px;}
.section-title{font-size:11px;font-weight:700;letter-spacing:.14em;text-transform:uppercase;color:var(--text-mid);margin-bottom:14px;padding-bottom:8px;border-bottom:1px solid var(--border);display:flex;align-items:center;gap:8px;}
.count-badge{font-family:var(--mono);font-size:10px;background:var(--bg4);border:1px solid var(--border);color:var(--text-mid);padding:1px 6px;border-radius:8px;}
.count-badge-fail{background:var(--fail-dim);border-color:var(--fail);color:var(--fail);}
.count-badge-pass{background:var(--pass-dim);border-color:var(--pass);color:var(--pass);}
.toggle-trigger{cursor:pointer;user-select:none;}
.toggle-trigger:hover{color:var(--accent);}
.section-toggle{margin-left:auto;font-size:10px;color:var(--text-dim);}

/* ── Suite overview grid ── */
.suite-grid-section{margin-bottom:36px;}
.suite-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:12px;}
.suite-card{display:block;background:var(--bg2);border:1px solid var(--border);border-radius:var(--radius);padding:14px 16px;cursor:pointer;transition:border-color .15s,transform .1s;}
.suite-card:hover{border-color:var(--accent);transform:translateY(-1px);}
.suite-card-pass{border-left:3px solid var(--pass);}
.suite-card-fail{border-left:3px solid var(--fail);}
.suite-card-top{display:flex;align-items:flex-start;justify-content:space-between;margin-bottom:10px;gap:8px;}
.suite-card-name{font-family:var(--mono);font-size:12px;font-weight:600;color:#fff;word-break:break-word;line-height:1.3;}
.suite-ico{font-size:14px;font-weight:700;flex-shrink:0;margin-top:1px;}
.suite-ico-pass{color:var(--pass);}
.suite-ico-fail{color:var(--fail);}
.suite-card-bar-wrap{height:3px;display:flex;border-radius:2px;overflow:hidden;background:var(--bg4);margin-bottom:8px;}
.suite-card-bar-pass{background:var(--pass);}
.suite-card-bar-fail{background:var(--fail);}
.suite-card-stats{display:flex;align-items:center;justify-content:space-between;}
.suite-pass-count{font-family:var(--mono);font-size:11px;color:var(--text-mid);}
.suite-type-tag{font-size:9px;letter-spacing:.1em;text-transform:uppercase;color:var(--text-dim);background:var(--bg4);padding:1px 5px;border-radius:3px;}
.suite-card-excerpt{font-family:var(--mono);font-size:10px;color:var(--fail);margin-top:8px;line-height:1.4;word-break:break-word;}

/* ── Per-suite section ── */
.suite-section{background:var(--bg2);border:1px solid var(--border);border-radius:var(--radius);margin-bottom:20px;overflow:hidden;}
.suite-section-header{display:flex;align-items:center;justify-content:space-between;padding:14px 20px;border-bottom:1px solid var(--border);background:var(--bg3);}
.suite-section-title{display:flex;align-items:center;gap:10px;}
.suite-section-verdict{font-size:16px;font-weight:700;}
.suite-section-verdict.pass{color:var(--pass);}
.suite-section-verdict.fail{color:var(--fail);}
.suite-section-name{font-family:var(--mono);font-size:14px;font-weight:600;color:#fff;}
.suite-mini-stats{font-family:var(--mono);font-size:11px;color:var(--text-dim);}
.back-link{font-family:var(--mono);font-size:11px;color:var(--text-dim);transition:color .15s;}
.back-link:hover{color:var(--accent);}
.suite-props{padding:8px 20px;background:var(--bg);border-bottom:1px solid var(--border);display:flex;flex-wrap:wrap;gap:12px;}
.prop-item{display:flex;align-items:center;gap:4px;}
.prop-key{font-family:var(--mono);font-size:10px;color:var(--text-dim);letter-spacing:.08em;}
.prop-val{font-family:var(--mono);font-size:10px;color:var(--accent);background:var(--bg3);padding:1px 6px;border-radius:3px;}
.suite-section-bar-wrap{height:2px;display:flex;background:var(--bg4);}
.suite-section-bar-pass{background:var(--pass);}
.suite-section-bar-fail{background:var(--fail);}

/* ── Matrix ── */
.matrix-section{padding:20px;}
.matrix-legend{display:flex;align-items:center;gap:16px;margin-bottom:16px;}
.legend-item{display:flex;align-items:center;gap:6px;font-family:var(--mono);font-size:11px;color:var(--text-mid);}
.legend-swatch{width:14px;height:14px;border-radius:2px;display:inline-block;}
.pass-swatch{background:var(--pass);}
.fail-swatch{background:var(--fail);}
.legend-tip{font-size:10px;color:var(--text-dim);margin-left:auto;}
.matrix-scroll{overflow-x:auto;}
.matrix-wrap{display:flex;flex-wrap:wrap;gap:28px;min-width:max-content;}
.matrix-block{}
.matrix-group-label{font-family:var(--mono);font-size:10px;color:var(--text-dim);letter-spacing:.1em;text-transform:uppercase;margin-bottom:8px;}
.matrix-table{border-collapse:collapse;}
.matrix-table .ax-label{font-family:var(--mono);font-size:9px;color:var(--accent);letter-spacing:.1em;text-transform:uppercase;text-align:left;padding:0 6px 6px 0;}
.matrix-table thead th{font-family:var(--mono);font-size:10px;color:var(--text-dim);padding:3px 6px;text-align:center;white-space:nowrap;border-bottom:1px solid var(--border);}
.matrix-table .row-label{font-family:var(--mono);font-size:10px;color:var(--text-mid);padding:3px 10px 3px 0;white-space:nowrap;text-align:left;}
.matrix-table td{width:34px;height:34px;border:2px solid var(--bg);cursor:default;transition:opacity .12s;}
.matrix-table td:hover{opacity:.7;outline:2px solid rgba(255,255,255,.3);}
.cell-pass{background:var(--pass);}
.cell-fail{background:var(--fail);}
.cell-empty{background:var(--bg3);}

/* ── Functional table ── */
.ft-table-wrap{padding:0;}
.ft-table{width:100%;border-collapse:collapse;}
.ft-table thead th{background:var(--bg3);color:var(--text-dim);font-size:9px;letter-spacing:.12em;text-transform:uppercase;font-weight:600;padding:9px 16px;text-align:left;border-bottom:1px solid var(--border);}
.ft-table tbody tr{border-bottom:1px solid var(--border);transition:background .08s;}
.ft-table tbody tr:last-child{border-bottom:none;}
.ft-table tbody tr:hover{background:var(--bg3);}
.ft-table tbody tr.row-fail{background:#160208;}
.ft-table tbody tr.row-fail:hover{background:#200310;}
.ft-table tbody tr.row-skip{background:#1a1500;}
.ft-table td{padding:10px 16px;font-size:12px;vertical-align:top;}
.ft-num{width:36px;color:var(--text-dim);font-size:11px;}
.ft-name .mono{font-size:12px;word-break:break-word;}
.inline-fail{font-family:var(--mono);font-size:10px;color:var(--fail);margin-top:4px;line-height:1.4;word-break:break-word;}

/* ── Failure cards ── */
.failures-list{padding:16px 20px;display:flex;flex-direction:column;gap:10px;}
.failure-card{background:var(--bg3);border:1px solid var(--fail-dim);border-left:3px solid var(--fail);border-radius:var(--radius);overflow:hidden;}
.failure-header{display:flex;align-items:center;gap:12px;padding:10px 14px;cursor:pointer;user-select:none;}
.failure-header:hover{background:var(--bg4);}
.failure-name{font-family:var(--mono);font-size:11px;color:var(--text);flex:1;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;}
.failure-type{font-family:var(--mono);font-size:10px;color:var(--fail);background:var(--fail-bg);padding:1px 7px;border-radius:3px;white-space:nowrap;}
.failure-toggle{color:var(--text-dim);font-size:9px;flex-shrink:0;}
.failure-meta{padding:0 14px 8px;display:flex;gap:14px;}
.failure-detail{border-top:1px solid var(--border);padding:14px;}
.assert-block{font-family:var(--mono);font-size:10px;line-height:1.8;white-space:pre-wrap;word-break:break-all;background:var(--bg);padding:12px 14px;border-radius:4px;border:1px solid var(--border);}
.assert-main{color:#ff7070;font-weight:600;}
.assert-where{color:#7da8e8;}
.assert-detail{color:var(--text-mid);}
.assert-line{color:var(--text-dim);}

/* ── Full test table ── */
.table-controls{display:flex;gap:10px;margin-bottom:10px;align-items:center;padding-top:4px;}
#search{background:var(--bg2);border:1px solid var(--border);border-radius:var(--radius);padding:7px 12px;color:var(--text);font-family:var(--mono);font-size:11px;width:240px;outline:none;}
#search:focus{border-color:var(--accent);}
.filter-pills{display:flex;gap:5px;}
.pill{background:var(--bg2);border:1px solid var(--border);color:var(--text-mid);font-size:10px;letter-spacing:.08em;padding:5px 13px;border-radius:20px;cursor:pointer;transition:all .12s;}
.pill:hover{border-color:var(--accent);color:var(--accent);}
.pill.active{background:var(--accent);border-color:var(--accent);color:var(--bg);font-weight:700;}
.table-wrap{background:var(--bg2);border:1px solid var(--border);border-radius:var(--radius);overflow-x:auto;}
#tests-table{width:100%;border-collapse:collapse;}
#tests-table thead th{background:var(--bg3);color:var(--text-dim);font-size:9px;letter-spacing:.12em;text-transform:uppercase;font-weight:600;padding:9px 12px;text-align:left;border-bottom:1px solid var(--border);white-space:nowrap;}
.sortable{cursor:pointer;}.sortable:hover{color:var(--accent);}
#tests-table tbody tr{border-bottom:1px solid var(--border);transition:background .08s;}
#tests-table tbody tr:last-child{border-bottom:none;}
#tests-table tbody tr:hover{background:var(--bg3);}
#tests-table tbody tr.row-fail{background:#130207;}
#tests-table tbody tr.row-fail:hover{background:#1d0310;}
#tests-table td{padding:8px 12px;font-size:11px;vertical-align:top;}
.suite-cell{color:var(--text-dim);font-size:10px;max-width:120px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;}
.name-cell{max-width:340px;word-break:break-all;font-size:10px;}
.num{text-align:right;color:var(--accent2);}
.dim{color:var(--text-dim);}
.mono{font-family:var(--mono);}
.fail-cell{max-width:280px;}
.err-type{font-family:var(--mono);font-size:9px;color:var(--fail);}
.err-msg{font-family:var(--mono);font-size:9px;color:var(--text-dim);word-break:break-all;}
.table-footer{font-family:var(--mono);font-size:10px;color:var(--text-dim);padding:8px 0 0;}

/* ── Badges ── */
.badge{font-family:var(--mono);font-size:9px;font-weight:700;letter-spacing:.08em;padding:2px 7px;border-radius:3px;display:inline-block;text-transform:uppercase;}
.badge-pass{background:var(--pass-dim);color:var(--pass);border:1px solid var(--pass-dim);}
.badge-fail{background:var(--fail-dim);color:var(--fail);border:1px solid var(--fail-dim);}
.badge-skip{background:#2a2000;color:var(--skip);border:1px solid #554000;}
.badge-error{background:#251000;color:#ff9040;border:1px solid #602800;}

/* ── Misc ── */
footer{text-align:center;padding:20px;font-family:var(--mono);font-size:10px;color:var(--text-dim);border-top:1px solid var(--border);margin-top:32px;}
"""


# ══════════════════════════════════════════════════════════════════════════════
#  CLI
# ══════════════════════════════════════════════════════════════════════════════

USAGE = """\
junit2html

  Merge XML files (GitLab-CI compatible output):
    junit2html --merge <out.xml> <in1.xml> [in2.xml ...]

  Dashboard with suite overview + matrix as hero:
    junit2html --report-matrix <out.html> <in.xml>

  Detailed HTML report:
    junit2html <in.xml> [out.html]

  Text summary + parameter matrix to stdout:
    junit2html --summary-matrix <in.xml> [--max-failures N]
"""


def _parse_args(argv):
    flags, opts, positional = set(), {}, []
    i = 0
    while i < len(argv):
        a = argv[i]
        if a in ("--merge", "--report-matrix", "--summary-matrix"):
            flags.add(a)
        elif a == "--max-failures":
            i += 1
            opts["max_failures"] = argv[i] if i < len(argv) else "20"
        elif a.startswith("--"):
            print("Warning: unknown flag {}".format(a), file=sys.stderr)
        else:
            positional.append(a)
        i += 1
    return {"flags": flags, "opts": opts, "positional": positional}


def main(argv=None):
    if argv is None:
        argv = sys.argv[1:]
    if not argv:
        print(USAGE)
        sys.exit(0)

    p = _parse_args(argv)
    flags, opts, pos = p["flags"], p["opts"], p["positional"]

    if "--merge" in flags:
        if len(pos) < 2:
            print("--merge requires: <out.xml> <in1.xml> [in2.xml ...]", file=sys.stderr)
            sys.exit(1)
        cmd_merge(output_xml=pos[0], input_paths=pos[1:])

    elif "--report-matrix" in flags:
        if len(pos) < 2:
            print("--report-matrix requires: <out.html> <in.xml>", file=sys.stderr)
            sys.exit(1)
        cmd_html(input_xml=pos[1], output_html=pos[0], matrix_first=True)

    elif "--summary-matrix" in flags:
        if not pos:
            print("--summary-matrix requires: <in.xml>", file=sys.stderr)
            sys.exit(1)
        cmd_summary_matrix(input_xml=pos[0],
                           max_failures=int(opts.get("max_failures", "20")))

    else:
        if not pos:
            print(USAGE)
            sys.exit(1)
        input_xml   = pos[0]
        output_html = pos[1] if len(pos) > 1 else str(Path(input_xml).with_suffix(".html"))
        cmd_html(input_xml=input_xml, output_html=output_html, matrix_first=False)


if __name__ == "__main__":
    main()
