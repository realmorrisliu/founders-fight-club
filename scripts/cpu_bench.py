#!/usr/bin/env python3

from __future__ import annotations

import argparse
import hashlib
import json
import os
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path


STAGE_LEFT = 70.0
STAGE_RIGHT = 830.0
OFF_X_PAD = 4.0
BELOW_Y = 400.0
LAUNCH_LOOKBACK = 20
P1 = "elon_mvsk"
P2 = "mark_zuck"


def offstage(player: dict) -> bool:
	x = float(player["x"])
	y = float(player["y"])
	return x < STAGE_LEFT - OFF_X_PAD or x > STAGE_RIGHT + OFF_X_PAD or y > BELOW_Y


def onstage_grounded(player: dict) -> bool:
	x = float(player["x"])
	return STAGE_LEFT <= x <= STAGE_RIGHT and bool(player.get("on_floor"))


def player_by_id(row: dict, side: str) -> dict:
	for player in row["players"]:
		if player.get("id") == side:
			return player
	raise KeyError(side)


def load_rows(path: Path) -> list[dict]:
	rows = []
	for line in path.read_text().splitlines():
		if line.strip():
			rows.append(json.loads(line))
	return rows


def score_log(rows: list[dict], sides: tuple[str, ...]) -> dict:
	episodes = []
	returned_to_stage = False
	stock_losses = 0
	voluntary_losses = 0
	launched_success = 0
	launched_fail = 0
	voluntary_success = 0
	incomplete = 0
	open_eps: dict[str, dict | None] = {side: None for side in sides}
	history: dict[str, list[dict]] = {side: [] for side in sides}

	for row in rows:
		for side in sides:
			player = player_by_id(row, side)
			prior = history[side]
			was_launched = False
			if prior:
				window = prior[-LAUNCH_LOOKBACK:]
				percent_now = int(player.get("percent", 0))
				was_launched = any(
					item["state"] in ("hitstun", "knockdown") or int(item["percent"]) < percent_now
					for item in window
				)
			episode = open_eps[side]
			if episode is None and offstage(player):
				episode = {
					"side": side,
					"start_frame": int(row["frame"]),
					"launched": was_launched,
					"stocks": int(player.get("stocks", 0)),
					"result": "",
				}
				open_eps[side] = episode
			elif episode is not None:
				stocks = int(player.get("stocks", 0))
				if stocks < episode["stocks"]:
					episode["result"] = "fail"
					stock_losses += 1
					if episode["launched"]:
						launched_fail += 1
					else:
						voluntary_losses += 1
					episodes.append(episode)
					open_eps[side] = None
				elif onstage_grounded(player):
					episode["result"] = "success"
					if episode["launched"]:
						launched_success += 1
					else:
						voluntary_success += 1
					episodes.append(episode)
					open_eps[side] = None
			if onstage_grounded(player) and side == "p2":
				returned_to_stage = True
			history[side].append(
				{
					"state": str(player.get("state", "")),
					"percent": int(player.get("percent", 0)),
				}
			)

	for episode in open_eps.values():
		if episode is not None:
			episode["result"] = "incomplete"
			episodes.append(episode)
			incomplete += 1

	ended_frame = None
	winner = ""
	for row in rows:
		if row.get("phase") == "ended":
			ended_frame = int(row["frame"])
			winner = str(row.get("winner", ""))
			break
	last = rows[-1] if rows else {}
	decided = winner in ("p1_win", "p2_win")
	return {
		"frames": len(rows),
		"ended_frame": ended_frame,
		"censored": ended_frame is None,
		"winner": winner,
		"decided": decided,
		"final_stocks": {
			side: int(player_by_id(last, side).get("stocks", 0)) for side in sides
		}
		if last
		else {},
		"stock_losses": stock_losses,
		"voluntary_losses": voluntary_losses,
		"launched_success": launched_success,
		"launched_fail": launched_fail,
		"voluntary_success": voluntary_success,
		"incomplete": incomplete,
		"returned_to_stage": returned_to_stage,
		"final_positions": {
			side: {
				"x": player_by_id(last, side).get("x"),
				"y": player_by_id(last, side).get("y"),
				"on_floor": player_by_id(last, side).get("on_floor"),
				"stocks": player_by_id(last, side).get("stocks"),
				"state": player_by_id(last, side).get("state"),
			}
			for side in sides
		}
		if last
		else {},
	}


def rate(numer: int, denom: int) -> float | None:
	if denom <= 0:
		return None
	return numer / denom


def run_ffc(repo: Path, args: list[str], out_path: Path) -> dict:
	out_path.parent.mkdir(parents=True, exist_ok=True)
	command = ["bash", "scripts/ffc.sh", "run", *args, "--out", str(out_path)]
	completed = subprocess.run(
		command,
		cwd=repo,
		text=True,
		stdout=subprocess.PIPE,
		stderr=subprocess.PIPE,
		check=False,
	)
	digest = ""
	for line in completed.stdout.splitlines():
		if line.startswith("hash="):
			digest = line.split("=", 1)[1].strip()
	if digest == "" and out_path.exists():
		digest = hashlib.sha256(out_path.read_bytes()).hexdigest()
	return {
		"code": completed.returncode,
		"hash": digest,
		"stdout_tail": "\n".join(completed.stdout.splitlines()[-8:]),
		"stderr_tail": "\n".join(completed.stderr.splitlines()[-12:]),
	}


def jobs_for(difficulties: bool) -> list[dict]:
	seeds = list(range(1, 9))
	jobs = []
	for seed in seeds:
		jobs.append(
			{
				"kind": "versus",
				"seed": seed,
				"args": [
					"--seed",
					str(seed),
					"--mode",
					"local",
					"--frames",
					"4000",
					"--p1",
					P1,
					"--p2",
					P2,
					"--p1-control",
					"cpu",
					"--p2-control",
					"cpu",
					"--timer-seconds",
					"60",
				],
			}
		)
		jobs.append(
			{
				"kind": "near",
				"seed": seed,
				"args": [
					"--seed",
					str(seed),
					"--mode",
					"cpu",
					"--frames",
					"180",
					"--p1",
					P1,
					"--p2",
					P2,
					"--p1-control",
					"script",
					"--p2-control",
					"cpu",
					"--setup-p1-x",
					"400",
					"--setup-p1-y",
					"300",
					"--setup-p2-x",
					"880",
					"--setup-p2-y",
					"200",
				],
			}
		)
		jobs.append(
			{
				"kind": "deep",
				"seed": seed,
				"args": [
					"--seed",
					str(seed),
					"--mode",
					"cpu",
					"--frames",
					"180",
					"--p1",
					P1,
					"--p2",
					P2,
					"--p1-control",
					"script",
					"--p2-control",
					"cpu",
					"--setup-p1-x",
					"400",
					"--setup-p1-y",
					"300",
					"--setup-p2-x",
					"900",
					"--setup-p2-y",
					"460",
				],
			}
		)
	for seed in range(1, 5):
		jobs.append(
			{
				"kind": "idle",
				"seed": seed,
				"args": [
					"--seed",
					str(seed),
					"--mode",
					"cpu",
					"--frames",
					"600",
					"--p1",
					P1,
					"--p2",
					P2,
					"--p1-control",
					"cpu",
					"--p2-control",
					"script",
					"--setup-p1-x",
					"330",
					"--setup-p1-y",
					"300",
					"--setup-p2-x",
					"570",
					"--setup-p2-y",
					"300",
				],
			}
		)
	jobs.append(
		{
			"kind": "versus_repeat",
			"seed": 1,
			"args": [
				"--seed",
				"1",
				"--mode",
				"local",
				"--frames",
				"4000",
				"--p1",
				P1,
				"--p2",
				P2,
				"--p1-control",
				"cpu",
				"--p2-control",
				"cpu",
				"--timer-seconds",
				"60",
			],
		}
	)
	if difficulties:
		for seed in seeds:
			jobs.append(
				{
					"kind": "hard_easy",
					"seed": seed,
					"args": [
						"--seed",
						str(seed),
						"--mode",
						"local",
						"--frames",
						"4000",
						"--p1",
						P1,
						"--p2",
						P2,
						"--p1-control",
						"cpu",
						"--p2-control",
						"cpu",
						"--timer-seconds",
						"60",
						"--p1-cpu-difficulty",
						"hard",
						"--p2-cpu-difficulty",
						"easy",
					],
				}
			)
	return jobs


def placement_stock_intact_over_slab(score: dict) -> bool:
	p2 = score["final_positions"].get("p2", {})
	touched_stage = bool(score.get("returned_to_stage"))
	y = float(p2.get("y", 9999))
	return (
		int(p2.get("stocks", 0)) == 3
		and touched_stage
		and STAGE_LEFT <= float(p2.get("x", -9999)) <= STAGE_RIGHT
		and y < BELOW_Y
	)


def summarize(records: list[dict]) -> dict:
	def of(kind: str) -> list[dict]:
		return [record for record in records if record["kind"] == kind and record["code"] == 0]

	versus = of("versus")
	lengths = []
	censored = 0
	for record in versus:
		score = record["score"]
		if score["ended_frame"] is None:
			censored += 1
			lengths.append(score["frames"])
		else:
			lengths.append(score["ended_frame"])
	launched_success = 0
	launched_fail = 0
	stock_losses = 0
	voluntary = 0
	for record in versus:
		score = record["score"]
		launched_success += score["launched_success"]
		launched_fail += score["launched_fail"]
		stock_losses += score["stock_losses"]
		voluntary += score["voluntary_losses"]
	idle = of("idle")
	idle_losses = sum(record["score"]["stock_losses"] for record in idle)
	idle_matches_with_loss = sum(1 for record in idle if record["score"]["stock_losses"] > 0)
	near = of("near")
	deep = of("deep")
	near_ok = sum(1 for record in near if placement_stock_intact_over_slab(record["score"]))
	deep_ok = sum(1 for record in deep if placement_stock_intact_over_slab(record["score"]))
	hard = of("hard_easy")
	hard_wins = sum(1 for record in hard if record["score"]["winner"] == "p1_win")
	easy_wins = sum(1 for record in hard if record["score"]["winner"] == "p2_win")
	decided = hard_wins + easy_wins
	repeat = of("versus_repeat")
	first = next((record for record in versus if record["seed"] == 1), None)
	deterministic = None
	if first is not None and repeat:
		deterministic = first["hash"] == repeat[0]["hash"] and first["hash"] != ""
	failures = [record for record in records if record["code"] != 0]
	return {
		"matches": {
			"versus": len(versus),
			"near": len(near),
			"deep": len(deep),
			"idle": len(idle),
			"hard_easy": len(hard),
			"failed_jobs": len(failures),
		},
		"self_destruct_rate": 0.0 if stock_losses == 0 else voluntary / stock_losses,
		"self_destruct_counts": {
			"voluntary_losses": voluntary,
			"stock_losses": stock_losses,
			"idle_stock_losses": idle_losses,
			"idle_matches_with_loss": idle_matches_with_loss,
			"idle_matches": len(idle),
		},
		"recovery_success_rate": rate(launched_success, launched_success + launched_fail),
		"recovery_counts": {
			"launched_success": launched_success,
			"launched_fail": launched_fail,
		},
		"placement_recovery": {
			"near_success_rate": rate(near_ok, len(near)),
			"deep_success_rate": rate(deep_ok, len(deep)),
			"near_success": near_ok,
			"deep_success": deep_ok,
		},
		"avg_match_length_frames": (sum(lengths) / len(lengths)) if lengths else None,
		"match_length": {
			"censored": censored,
			"samples": lengths,
		},
		"hard_beats_easy_win_rate": None if not hard else rate(hard_wins, decided),
		"hard_easy_counts": {
			"hard_wins": hard_wins,
			"easy_wins": easy_wins,
			"undecided": len(hard) - decided,
		},
		"seed_repeat_matches": deterministic,
		"failed_jobs": [
			{"kind": record["kind"], "seed": record["seed"], "stderr_tail": record["stderr_tail"]}
			for record in failures
		],
	}


def main() -> int:
	parser = argparse.ArgumentParser(description="Run CPU behavior bars through ffc.sh")
	parser.add_argument("--out", required=True, help="Directory for logs and summary.json")
	parser.add_argument("--jobs", type=int, default=3, help="Parallel Godot processes")
	parser.add_argument(
		"--difficulties",
		action="store_true",
		help="Also run hard P1 vs easy P2. Requires driver --p1-cpu-difficulty.",
	)
	parser.add_argument("--repo", default=".", help="Repository root")
	args = parser.parse_args()
	repo = Path(args.repo).resolve()
	out_dir = Path(args.out).resolve()
	out_dir.mkdir(parents=True, exist_ok=True)
	planned = jobs_for(args.difficulties)

	def execute(job: dict) -> dict:
		name = f"{job['kind']}-seed-{job['seed']}.jsonl"
		if job["kind"] == "versus_repeat":
			name = "versus-seed-1-repeat.jsonl"
		log_path = out_dir / name
		ran = run_ffc(repo, job["args"], log_path)
		score = {}
		if ran["code"] == 0 and log_path.exists() and log_path.stat().st_size > 0:
			sides = ("p2",) if job["kind"] in ("near", "deep") else ("p1", "p2")
			if job["kind"] == "idle":
				sides = ("p1",)
			score = score_log(load_rows(log_path), sides)
		return {**job, **ran, "score": score, "log": str(log_path)}

	records = []
	with ThreadPoolExecutor(max_workers=max(1, args.jobs)) as pool:
		futures = [pool.submit(execute, job) for job in planned]
		for future in as_completed(futures):
			record = future.result()
			records.append(record)
			print(
				f"{record['kind']} seed={record['seed']} code={record['code']} hash={record['hash'][:12]}",
				flush=True,
			)
	records.sort(key=lambda record: (record["kind"], record["seed"]))
	summary = summarize(records)
	(out_dir / "summary.json").write_text(json.dumps(summary, indent=2) + "\n")
	slim = []
	for record in records:
		slim.append(
			{
				"kind": record["kind"],
				"seed": record["seed"],
				"code": record["code"],
				"hash": record["hash"],
				"score": record["score"],
			}
		)
	(out_dir / "records.json").write_text(json.dumps(slim, indent=2) + "\n")
	print(json.dumps(summary, indent=2))
	return 1 if summary["matches"]["failed_jobs"] else 0


if __name__ == "__main__":
	sys.exit(main())
