#!/usr/bin/env python3
"""Run track example solutions through the production test-runner container."""

import argparse
import fnmatch
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("exercises", nargs="*", help="exercise names or quoted globs (default: all)")
    parser.add_argument("--track", type=Path, required=True)
    parser.add_argument("--image", default=os.environ.get("TEST_RUNNER_IMAGE", "exercism/roc-test-runner"))
    parser.add_argument("--skip-build", action="store_true", help="reuse the existing local image")
    parser.add_argument("--output", type=Path, help="parent for a new results directory (default: system temp)")
    parser.add_argument("--timeout", type=int, default=60, help="seconds per exercise inside the container (default: 60)")
    args = parser.parse_args()
    if args.timeout <= 0:
        parser.error("--timeout must be positive")
    if not shutil.which("docker"):
        parser.error("docker must be installed and available in PATH")

    track = args.track.expanduser().resolve()
    configs = sorted(track.glob("exercises/*/*/.meta/config.json"))
    patterns = args.exercises or ["*"]
    for pattern in patterns:
        if not any(fnmatch.fnmatch(p.parent.parent.name, pattern) for p in configs):
            parser.error(f"no exercises match {pattern!r} in {track}")
    configs = [p for p in configs if any(fnmatch.fnmatch(p.parent.parent.name, g) for g in patterns)]
    root = Path(__file__).resolve().parent.parent
    if args.output:
        args.output = args.output.expanduser().resolve()
        args.output.mkdir(parents=True, exist_ok=True)
    output = Path(tempfile.mkdtemp(prefix="roc-track-results-", dir=args.output)).resolve()
    print(f"Results: {output}", flush=True)

    with tempfile.TemporaryDirectory(prefix="roc-track-work-") as work_dir:
        work = Path(work_dir).resolve()
        if not args.skip_build:
            iid = work / "image-id"
            subprocess.run([
                "docker", "build", "--platform", "linux/amd64", "--iidfile", str(iid),
                "-t", args.image, str(root),
            ], check=True)
            image = iid.read_text().strip()
        else:
            # Run the exact local image, avoiding Podman's short-name registry lookup.
            image = subprocess.check_output([
                "docker", "image", "inspect", "--format", "{{.Id}}", args.image,
            ], text=True).strip()

        failed = []
        for index, config in enumerate(configs, 1):
            exercise = config.parent.parent
            slug = exercise.name
            label = f"{exercise.parent.name}/{slug}"
            result_dir = output / label
            result_dir.mkdir(parents=True)
            print(f"[{index}/{len(configs)}] {label}: ", end="", flush=True)
            try:
                files = json.loads(config.read_text())["files"]
                solutions = files["solution"]
                examples = files.get("exemplar", files.get("example", []))
                if not solutions or len(solutions) != len(examples):
                    raise ValueError("solution and example/exemplar file lists must match")
                with tempfile.TemporaryDirectory(dir=work) as staging:
                    solution = Path(staging) / "solution"
                    shutil.copytree(exercise, solution)
                    for src, dst in zip(examples, solutions):
                        target = solution / dst
                        target.parent.mkdir(parents=True, exist_ok=True)
                        shutil.copyfile(solution / src, target)
                    with (result_dir / "runner.log").open("w") as log:
                        run = subprocess.run([
                            "docker", "run", "--rm", "--platform", "linux/amd64",
                            "--network", "none", "--read-only",
                            "--mount", f"type=bind,src={solution},dst=/solution,readonly",
                            "--mount", f"type=bind,src={result_dir},dst=/output",
                            "--mount", "type=volume,dst=/tmp",
                            "--entrypoint", "timeout", image,
                            "--kill-after=5s", f"{args.timeout}s",
                            "/opt/test-runner/bin/run.sh", slug, "/solution", "/output",
                        ], stdout=log, stderr=subprocess.STDOUT)
                    if run.returncode:
                        raise ValueError(f"container exited {run.returncode} (124/137 may indicate timeout); see runner.log")
                    result = json.loads((result_dir / "results.json").read_text())
                    status = result["status"]
                    if status != "pass":
                        failed.append(label)
                    print(status.upper(), flush=True)
            except (OSError, ValueError, KeyError) as error:
                failed.append(label)
                (result_dir / "error.txt").write_text(f"{error}\n")
                print(f"ERROR: {error}", flush=True)

    print(f"\n{len(configs) - len(failed)} passed, {len(failed)} failed out of {len(configs)} exercises.")
    if failed:
        print("Failed exercises: " + ", ".join(failed))
    print(f"Results and logs: {output}")
    return int(bool(failed))


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except subprocess.CalledProcessError as error:
        raise SystemExit(error.returncode)
    except KeyboardInterrupt:
        raise SystemExit(130)
