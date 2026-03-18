#!/usr/bin/env python3
"""Summarize match telemetry funnels for local review."""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
from collections import Counter
from pathlib import Path
from typing import Any


def _repo_root() -> Path:
    return Path(__file__).resolve().parents[2]


def _project_name(repo_root: Path) -> str:
    project_path = repo_root / "project.godot"
    if not project_path.exists():
        return repo_root.name
    content = project_path.read_text(encoding="utf-8")
    match = re.search(r'^config/name="([^"]+)"', content, re.MULTILINE)
    if match:
        return match.group(1)
    return repo_root.name


def _candidate_paths(repo_root: Path, project_name: str) -> list[Path]:
    home = Path.home()
    repo_test_home = repo_root / ".godot-test-home"
    candidates = [
        repo_test_home
        / "Library/Application Support/Godot/app_userdata"
        / project_name
        / "match_metrics.jsonl",
        repo_test_home / ".local/share/godot/app_userdata" / project_name / "match_metrics.jsonl",
        home
        / "Library/Application Support/Godot/app_userdata"
        / project_name
        / "match_metrics.jsonl",
        home / ".local/share/godot/app_userdata" / project_name / "match_metrics.jsonl",
    ]
    appdata = os.environ.get("APPDATA", "").strip()
    if appdata:
        candidates.append(Path(appdata) / "Godot" / "app_userdata" / project_name / "match_metrics.jsonl")
    return candidates


def _resolve_input_path(repo_root: Path, input_path: str) -> Path:
    if input_path.strip():
        return Path(input_path).expanduser()
    project_name = _project_name(repo_root)
    candidates = _candidate_paths(repo_root, project_name)
    for candidate in candidates:
        if candidate.exists():
            return candidate
    return candidates[0]


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Summarize training drill and onboarding lesson funnels from match_metrics.jsonl."
    )
    parser.add_argument(
        "--input",
        default="",
        help="Path to match_metrics.jsonl. Defaults to the repo test-home metrics path when available.",
    )
    parser.add_argument(
        "--limit",
        type=int,
        default=20,
        help="Analyze only the most recent N records. Use 0 to analyze all records. Default: 20.",
    )
    parser.add_argument(
        "--format",
        choices=["text", "json"],
        default="text",
        help="Output format. Default: text.",
    )
    return parser


def _read_records(path: Path, limit: int) -> list[dict[str, Any]]:
    if not path.exists():
        raise FileNotFoundError(f"Metrics log not found: {path}")
    records: list[dict[str, Any]] = []
    with path.open("r", encoding="utf-8") as handle:
        for line_number, line in enumerate(handle, start=1):
            stripped = line.strip()
            if not stripped:
                continue
            try:
                payload = json.loads(stripped)
            except json.JSONDecodeError as exc:
                raise ValueError(f"Invalid JSON on line {line_number}: {exc}") from exc
            if isinstance(payload, dict):
                records.append(payload)
    if limit > 0:
        return records[-limit:]
    return records


def _make_training_aggregate(drill_id: str) -> dict[str, Any]:
    return {
        "drill_id": drill_id,
        "session_count": 0,
        "rep_start_count": 0,
        "rep_result_count": 0,
        "success_count": 0,
        "fail_count": 0,
        "reset_count": 0,
        "completion_rate": 0.0,
        "success_rate": 0.0,
        "avg_result_seconds": 0.0,
        "avg_success_seconds": 0.0,
        "avg_fail_seconds": 0.0,
        "avg_closest_blast_margin_px": -1.0,
        "closest_blast_margin_sample_count": 0,
        "last_result": "",
        "last_reason": "",
        "reason_counts": {},
        "_result_seconds_sum": 0.0,
        "_success_seconds_sum": 0.0,
        "_fail_seconds_sum": 0.0,
        "_closest_margin_sum": 0.0,
    }


def _make_onboarding_aggregate(lesson_id: str) -> dict[str, Any]:
    return {
        "lesson_id": lesson_id,
        "session_count": 0,
        "start_count": 0,
        "retry_start_count": 0,
        "result_count": 0,
        "success_count": 0,
        "fail_count": 0,
        "completion_rate": 0.0,
        "success_rate": 0.0,
        "avg_attempt_seconds": 0.0,
        "avg_success_seconds": 0.0,
        "avg_fail_seconds": 0.0,
        "avg_attempt_index_on_success": 0.0,
        "last_result": "",
        "last_reason": "",
        "fail_reason_counts": {},
        "success_reason_counts": {},
        "_attempt_seconds_sum": 0.0,
        "_success_seconds_sum": 0.0,
        "_fail_seconds_sum": 0.0,
        "_success_attempt_index_sum": 0.0,
    }


def _merge_counter(target: dict[str, int], source: dict[str, Any]) -> dict[str, int]:
    counter = Counter(target)
    for key, value in source.items():
        counter[str(key)] += int(value)
    return dict(counter)


def _resolve_blast_margin_sample_count(funnel: dict[str, Any]) -> int:
    explicit_count = int(funnel.get("closest_blast_margin_sample_count", 0))
    if explicit_count > 0:
        return explicit_count
    legacy_avg_margin = float(funnel.get("avg_closest_blast_margin_px", -1.0))
    return 1 if legacy_avg_margin >= 0.0 else 0


def _aggregate_training_funnels(records: list[dict[str, Any]]) -> dict[str, dict[str, Any]]:
    aggregates: dict[str, dict[str, Any]] = {}
    for record in records:
        funnels = record.get("training_drill_funnels", {})
        if not isinstance(funnels, dict):
            continue
        for drill_id, funnel in funnels.items():
            if not isinstance(funnel, dict):
                continue
            key = str(drill_id).strip().lower()
            if not key:
                continue
            aggregate = aggregates.setdefault(key, _make_training_aggregate(key))
            aggregate["session_count"] += 1
            aggregate["rep_start_count"] += int(funnel.get("rep_start_count", 0))
            aggregate["rep_result_count"] += int(funnel.get("rep_result_count", 0))
            aggregate["success_count"] += int(funnel.get("success_count", 0))
            aggregate["fail_count"] += int(funnel.get("fail_count", 0))
            aggregate["reset_count"] += int(funnel.get("reset_count", 0))
            aggregate["_result_seconds_sum"] += float(funnel.get("avg_result_seconds", 0.0)) * int(
                funnel.get("rep_result_count", 0)
            )
            aggregate["_success_seconds_sum"] += float(funnel.get("avg_success_seconds", 0.0)) * int(
                funnel.get("success_count", 0)
            )
            aggregate["_fail_seconds_sum"] += float(funnel.get("avg_fail_seconds", 0.0)) * int(
                funnel.get("fail_count", 0)
            )
            margin_samples = _resolve_blast_margin_sample_count(funnel)
            if margin_samples > 0:
                aggregate["closest_blast_margin_sample_count"] += margin_samples
                aggregate["_closest_margin_sum"] += float(funnel.get("avg_closest_blast_margin_px", -1.0)) * margin_samples
            aggregate["reason_counts"] = _merge_counter(
                aggregate["reason_counts"], funnel.get("reason_counts", {})
            )
            aggregate["last_result"] = str(funnel.get("last_result", "")).strip().lower()
            aggregate["last_reason"] = str(funnel.get("last_reason", "")).strip().lower()
    for aggregate in aggregates.values():
        rep_start_count = int(aggregate["rep_start_count"])
        rep_result_count = int(aggregate["rep_result_count"])
        success_count = int(aggregate["success_count"])
        fail_count = int(aggregate["fail_count"])
        margin_samples = int(aggregate["closest_blast_margin_sample_count"])
        aggregate["completion_rate"] = rep_result_count / rep_start_count if rep_start_count else 0.0
        aggregate["success_rate"] = success_count / rep_result_count if rep_result_count else 0.0
        aggregate["avg_result_seconds"] = aggregate["_result_seconds_sum"] / rep_result_count if rep_result_count else 0.0
        aggregate["avg_success_seconds"] = aggregate["_success_seconds_sum"] / success_count if success_count else 0.0
        aggregate["avg_fail_seconds"] = aggregate["_fail_seconds_sum"] / fail_count if fail_count else 0.0
        aggregate["avg_closest_blast_margin_px"] = (
            aggregate["_closest_margin_sum"] / margin_samples if margin_samples else -1.0
        )
        del aggregate["_result_seconds_sum"]
        del aggregate["_success_seconds_sum"]
        del aggregate["_fail_seconds_sum"]
        del aggregate["_closest_margin_sum"]
    return aggregates


def _aggregate_onboarding_funnels(records: list[dict[str, Any]]) -> dict[str, dict[str, Any]]:
    aggregates: dict[str, dict[str, Any]] = {}
    for record in records:
        funnels = record.get("onboarding_lesson_funnels", {})
        if not isinstance(funnels, dict):
            continue
        for lesson_id, funnel in funnels.items():
            if not isinstance(funnel, dict):
                continue
            key = str(lesson_id).strip().lower()
            if not key:
                continue
            aggregate = aggregates.setdefault(key, _make_onboarding_aggregate(key))
            aggregate["session_count"] += 1
            aggregate["start_count"] += int(funnel.get("start_count", 0))
            aggregate["retry_start_count"] += int(funnel.get("retry_start_count", 0))
            aggregate["result_count"] += int(funnel.get("result_count", 0))
            aggregate["success_count"] += int(funnel.get("success_count", 0))
            aggregate["fail_count"] += int(funnel.get("fail_count", 0))
            aggregate["_attempt_seconds_sum"] += float(funnel.get("avg_attempt_seconds", 0.0)) * int(
                funnel.get("result_count", 0)
            )
            aggregate["_success_seconds_sum"] += float(funnel.get("avg_success_seconds", 0.0)) * int(
                funnel.get("success_count", 0)
            )
            aggregate["_fail_seconds_sum"] += float(funnel.get("avg_fail_seconds", 0.0)) * int(
                funnel.get("fail_count", 0)
            )
            aggregate["_success_attempt_index_sum"] += float(
                funnel.get("avg_attempt_index_on_success", 0.0)
            ) * int(funnel.get("success_count", 0))
            aggregate["fail_reason_counts"] = _merge_counter(
                aggregate["fail_reason_counts"], funnel.get("fail_reason_counts", {})
            )
            aggregate["success_reason_counts"] = _merge_counter(
                aggregate["success_reason_counts"], funnel.get("success_reason_counts", {})
            )
            aggregate["last_result"] = str(funnel.get("last_result", "")).strip().lower()
            aggregate["last_reason"] = str(funnel.get("last_reason", "")).strip().lower()
    for aggregate in aggregates.values():
        start_count = int(aggregate["start_count"])
        result_count = int(aggregate["result_count"])
        success_count = int(aggregate["success_count"])
        fail_count = int(aggregate["fail_count"])
        aggregate["completion_rate"] = result_count / start_count if start_count else 0.0
        aggregate["success_rate"] = success_count / result_count if result_count else 0.0
        aggregate["avg_attempt_seconds"] = aggregate["_attempt_seconds_sum"] / result_count if result_count else 0.0
        aggregate["avg_success_seconds"] = aggregate["_success_seconds_sum"] / success_count if success_count else 0.0
        aggregate["avg_fail_seconds"] = aggregate["_fail_seconds_sum"] / fail_count if fail_count else 0.0
        aggregate["avg_attempt_index_on_success"] = (
            aggregate["_success_attempt_index_sum"] / success_count if success_count else 0.0
        )
        del aggregate["_attempt_seconds_sum"]
        del aggregate["_success_seconds_sum"]
        del aggregate["_fail_seconds_sum"]
        del aggregate["_success_attempt_index_sum"]
    return aggregates


def _top_reasons(mapping: dict[str, Any], limit: int = 3) -> str:
    counter = Counter({str(key): int(value) for key, value in mapping.items()})
    if not counter:
        return "-"
    parts = [f"{reason} x{count}" for reason, count in counter.most_common(limit)]
    return ", ".join(parts)


def _format_rate(value: float) -> str:
    return f"{value * 100.0:.1f}%"


def _format_seconds(value: float) -> str:
    if value <= 0.0:
        return "-"
    return f"{value:.2f}s"


def _format_margin(value: float) -> str:
    if value < 0.0:
        return "-"
    return f"{value:.1f}px"


def _text_report(
    path: Path,
    records: list[dict[str, Any]],
    training_funnels: dict[str, dict[str, Any]],
    onboarding_funnels: dict[str, dict[str, Any]],
) -> str:
    lines = [
        f"Source: {path}",
        f"Sessions analyzed: {len(records)}",
        "",
        "Training Drills",
    ]
    if training_funnels:
        ordered_training = sorted(
            training_funnels.values(),
            key=lambda item: (-int(item["fail_count"]), float(item["success_rate"]), str(item["drill_id"])),
        )
        for funnel in ordered_training:
            lines.append(
                (
                    f"- {funnel['drill_id']}: sessions={funnel['session_count']} starts={funnel['rep_start_count']} "
                    f"results={funnel['rep_result_count']} success={funnel['success_count']} fail={funnel['fail_count']} "
                    f"reset={funnel['reset_count']} completion={_format_rate(float(funnel['completion_rate']))} "
                    f"success_rate={_format_rate(float(funnel['success_rate']))} avg_result={_format_seconds(float(funnel['avg_result_seconds']))} "
                    f"avg_fail={_format_seconds(float(funnel['avg_fail_seconds']))} blast_margin={_format_margin(float(funnel['avg_closest_blast_margin_px']))} "
                    f"reasons={_top_reasons(funnel['reason_counts'])}"
                )
            )
    else:
        lines.append("- No drill funnels found.")
    lines.extend(["", "Onboarding Lessons"])
    if onboarding_funnels:
        ordered_lessons = sorted(
            onboarding_funnels.values(),
            key=lambda item: (-int(item["fail_count"]), float(item["completion_rate"]), str(item["lesson_id"])),
        )
        for funnel in ordered_lessons:
            lines.append(
                (
                    f"- {funnel['lesson_id']}: sessions={funnel['session_count']} starts={funnel['start_count']} "
                    f"retries={funnel['retry_start_count']} results={funnel['result_count']} success={funnel['success_count']} "
                    f"fail={funnel['fail_count']} completion={_format_rate(float(funnel['completion_rate']))} "
                    f"success_rate={_format_rate(float(funnel['success_rate']))} "
                    f"avg_attempt={_format_seconds(float(funnel['avg_attempt_seconds']))} "
                    f"avg_success={_format_seconds(float(funnel['avg_success_seconds']))} "
                    f"avg_success_attempt={float(funnel['avg_attempt_index_on_success']):.2f} "
                    f"fail_reasons={_top_reasons(funnel['fail_reason_counts'])} "
                    f"success_reasons={_top_reasons(funnel['success_reason_counts'])}"
                )
            )
    else:
        lines.append("- No onboarding funnels found.")
    return "\n".join(lines)


def _json_report(
    path: Path,
    records: list[dict[str, Any]],
    training_funnels: dict[str, dict[str, Any]],
    onboarding_funnels: dict[str, dict[str, Any]],
) -> str:
    payload = {
        "source": str(path),
        "session_count": len(records),
        "training_drill_funnels": training_funnels,
        "onboarding_lesson_funnels": onboarding_funnels,
    }
    return json.dumps(payload, indent=2, ensure_ascii=False)


def main() -> int:
    args = _build_parser().parse_args()
    repo_root = _repo_root()
    path = _resolve_input_path(repo_root, args.input)
    try:
        records = _read_records(path, args.limit)
    except (FileNotFoundError, ValueError) as exc:
        print(str(exc), file=sys.stderr)
        return 1
    training_funnels = _aggregate_training_funnels(records)
    onboarding_funnels = _aggregate_onboarding_funnels(records)
    if args.format == "json":
        print(_json_report(path, records, training_funnels, onboarding_funnels))
    else:
        print(_text_report(path, records, training_funnels, onboarding_funnels))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
