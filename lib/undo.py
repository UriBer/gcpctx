#!/usr/bin/env python3
"""Inverse-plan builder for gcpctx history undo.

Reads classification + event metadata and prints inverse.json to stdout.
Does not execute cloud commands.
"""
from __future__ import annotations

import json
import sys
from typing import Any


def plan_local(ev: dict[str, Any]) -> dict[str, Any]:
    before = "before/meta.json"
    return {
        "status": "ready",
        "steps": [
            {
                "type": "restore_local_meta",
                "from": before,
                "active_from": "before/active",
            }
        ],
        "notes": ["Restore previous gcpctx active context and meta.json"],
    }


def plan_bigquery(ev: dict[str, Any], classification: dict[str, Any]) -> dict[str, Any]:
    action = classification.get("action") or ""
    resource = classification.get("resource") or ""
    snaps = ev.get("snapshots") or []
    deleted_at = None
    snapshot_table = None
    for s in snaps:
        if s.get("kind") == "bq_timetravel":
            deleted_at = s.get("deleted_at_ms")
            if not resource:
                resource = s.get("original") or s.get("resource") or ""
        if s.get("kind") == "bq_snapshot":
            snapshot_table = s.get("resource")

    if action in ("rm", "delete", "drop"):
        steps = []
        # Prefer snapshot table, else time travel
        if snapshot_table:
            steps.append(
                {
                    "type": "bq_cp",
                    "src": snapshot_table,
                    "dst": resource,
                    "args": ["-n"],
                    "prefer": True,
                }
            )
        if deleted_at and resource:
            # Normalize resource for bq: project:dataset.table
            src = resource
            if "@" not in src:
                src = f"{resource}@{deleted_at}"
            steps.append(
                {
                    "type": "bq_cp",
                    "src": src,
                    "dst": resource.split("@")[0] if "@" in resource else resource,
                    "args": ["-n"],
                    "prefer": False,
                    "deleted_at_ms": deleted_at,
                }
            )
        if not steps:
            return {
                "status": "unsupported",
                "steps": [],
                "notes": ["BQ delete without deleted_at or snapshot"],
            }
        return {
            "status": "ready",
            "steps": steps,
            "notes": [
                "Undo BQ delete: prefer snapshot table, else bq cp table@timestamp",
            ],
            "pick_order": ["bq_snapshot", "bq_timetravel"],
        }

    if action == "mk":
        return {
            "status": "ready",
            "steps": [{"type": "bq_rm", "resource": resource, "args": ["-f"]}],
            "notes": ["Undo bq mk by removing the created table/dataset"],
        }

    return {
        "status": "unsupported",
        "steps": [],
        "notes": [f"BQ action {action!r} is not auto-invertible without --snapshot"],
    }


def plan_cloudrun(ev: dict[str, Any], classification: dict[str, Any]) -> dict[str, Any]:
    action = classification.get("action") or ""
    resource = classification.get("resource") or ""
    before_rev = None
    for s in ev.get("snapshots") or []:
        if s.get("kind") == "cloudrun_revision":
            before_rev = s.get("resource")
    if action in ("deploy", "update") and before_rev:
        return {
            "status": "ready",
            "steps": [
                {
                    "type": "gcloud",
                    "argv": [
                        "run",
                        "services",
                        "update-traffic",
                        resource,
                        f"--to-revisions={before_rev}=100",
                    ],
                }
            ],
            "notes": ["Route 100% traffic to previous Cloud Run revision"],
        }
    if action == "delete" and (ev.get("before") or {}).get("service_json"):
        return {
            "status": "ready",
            "steps": [{"type": "cloudrun_recreate_from_before", "resource": resource}],
            "notes": ["Recreate service from before/service.json (best-effort)"],
        }
    return {
        "status": "unsupported",
        "steps": [],
        "notes": ["Cloud Run undo needs a prior revision snapshot"],
    }


def plan_iam(classification: dict[str, Any]) -> dict[str, Any]:
    action = classification.get("action") or ""
    if action == "add-iam-policy-binding":
        return {
            "status": "ready",
            "steps": [
                {
                    "type": "gcloud_invert_iam",
                    "from": "add-iam-policy-binding",
                    "to": "remove-iam-policy-binding",
                }
            ],
            "notes": ["Swap add-iam-policy-binding → remove-iam-policy-binding with same flags"],
        }
    if action == "remove-iam-policy-binding":
        return {
            "status": "ready",
            "steps": [
                {
                    "type": "gcloud_invert_iam",
                    "from": "remove-iam-policy-binding",
                    "to": "add-iam-policy-binding",
                }
            ],
            "notes": ["Swap remove → add IAM binding"],
        }
    if action == "create":
        return {
            "status": "ready",
            "steps": [
                {
                    "type": "gcloud",
                    "argv": [
                        "iam",
                        "service-accounts",
                        "delete",
                        classification.get("resource") or "",
                        "--quiet",
                    ],
                }
            ],
            "notes": ["Delete created service account"],
        }
    if action == "delete":
        return {
            "status": "unsupported",
            "steps": [],
            "notes": ["SA delete undo requires before/sa.json recreate recipe"],
        }
    return {"status": "unsupported", "steps": [], "notes": [f"IAM {action} unsupported"]}


def plan_gcs(classification: dict[str, Any]) -> dict[str, Any]:
    action = classification.get("action") or ""
    resource = classification.get("resource") or ""
    if action in ("mb", "mb -l"):
        return {
            "status": "ready",
            "steps": [{"type": "shell", "argv": ["gsutil", "rb", resource]}],
            "notes": ["Remove bucket created by mb"],
        }
    if "rb" in action:
        return {
            "status": "unsupported",
            "steps": [],
            "notes": ["Bucket delete undo needs before/ object copy"],
        }
    return {"status": "unsupported", "steps": [], "notes": [f"GCS {action} unsupported"]}


def plan_compute(classification: dict[str, Any]) -> dict[str, Any]:
    action = classification.get("action") or ""
    resource = classification.get("resource") or ""
    invert = {
        "start": "stop",
        "stop": "start",
        "create": "delete",
    }
    if action in invert:
        return {
            "status": "ready",
            "steps": [
                {
                    "type": "gcloud",
                    "argv": ["compute", "instances", invert[action], resource, "--quiet"],
                }
            ],
            "notes": [f"Invert compute instances {action} → {invert[action]}"],
        }
    if action == "delete":
        return {
            "status": "unsupported",
            "steps": [],
            "notes": ["Instance delete undo needs before/instance.json"],
        }
    return {"status": "unsupported", "steps": [], "notes": [f"compute {action} unsupported"]}


def plan_terraform(ev: dict[str, Any], classification: dict[str, Any]) -> dict[str, Any]:
    action = classification.get("action") or ""
    if action in ("apply", "destroy"):
        return {
            "status": "ready",
            "steps": [
                {
                    "type": "terraform_state_restore",
                    "state_snapshot": "before/terraform.tfstate",
                    "cwd": ev.get("cwd") or ".",
                }
            ],
            "notes": [
                "Restore terraform.tfstate from before/ then terraform apply (manual review recommended)"
            ],
        }
    return {"status": "unsupported", "steps": [], "notes": [f"terraform {action} unsupported"]}


def build_plan(ev: dict[str, Any], undo_cmd: str | None = None) -> dict[str, Any]:
    if undo_cmd:
        return {
            "status": "ready",
            "steps": [{"type": "shell_string", "cmd": undo_cmd}],
            "notes": ["User-provided --undo-cmd"],
        }
    classification = ev.get("classification") or {}
    family = classification.get("family") or "unknown"
    if family == "gcpctx_local":
        return plan_local(ev)
    if family == "bigquery":
        return plan_bigquery(ev, classification)
    if family == "cloudrun":
        return plan_cloudrun(ev, classification)
    if family == "iam":
        return plan_iam(classification)
    if family == "gcs":
        return plan_gcs(classification)
    if family == "compute":
        return plan_compute(classification)
    if family == "terraform":
        return plan_terraform(ev, classification)
    return {
        "status": "unsupported",
        "steps": [],
        "notes": [
            "Unclassified command; pass --undo-cmd on exec or use replay only",
        ],
    }


def main() -> None:
    if len(sys.argv) < 2:
        print("usage: undo.py <event.json> [--undo-cmd CMD]", file=sys.stderr)
        raise SystemExit(2)
    path = sys.argv[1]
    undo_cmd = None
    if "--undo-cmd" in sys.argv:
        i = sys.argv.index("--undo-cmd")
        if i + 1 < len(sys.argv):
            undo_cmd = sys.argv[i + 1]
    with open(path) as f:
        ev = json.load(f)
    plan = build_plan(ev, undo_cmd)
    print(json.dumps(plan, indent=2))


if __name__ == "__main__":
    main()
