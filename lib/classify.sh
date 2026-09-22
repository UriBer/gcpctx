# shellcheck shell=bash
# Classify wrapped command argv into undo families.

# Prints JSON: {family, action, resource, details}
# Usage: gcpctx_classify_argv -- cmd args...
gcpctx_classify_argv() {
  python3 -c '
import json, sys

argv = sys.argv[1:]
if not argv:
    print(json.dumps({"family": "unknown", "action": "none", "resource": "", "details": {}}))
    raise SystemExit(0)

# Strip leading env-like tokens
cmd0 = argv[0]
base = cmd0.rsplit("/", 1)[-1]

out = {
    "family": "unknown",
    "action": "run",
    "resource": "",
    "details": {"argv": argv},
}

def find_flag(args, name):
    for i, a in enumerate(args):
        if a == name and i + 1 < len(args):
            return args[i + 1]
        if a.startswith(name + "="):
            return a.split("=", 1)[1]
    return None

if base in ("gcloud", "gcloud.cmd"):
    rest = argv[1:]
    # skip global flags
    i = 0
    while i < len(rest) and rest[i].startswith("-"):
        if rest[i] in ("--project", "--configuration", "--account", "--format", "--verbosity"):
            i += 2
        else:
            i += 1
    rest = rest[i:]
    if not rest:
        pass
    elif rest[0] == "run":
        out["family"] = "cloudrun"
        if len(rest) >= 3 and rest[1] == "deploy":
            out["action"] = "deploy"
            out["resource"] = rest[2]
        elif len(rest) >= 3 and rest[1] == "services":
            out["action"] = rest[2]  # update|delete|describe
            if len(rest) > 3 and not rest[3].startswith("-"):
                out["resource"] = rest[3]
    elif rest[0] == "iam":
        out["family"] = "iam"
        out["action"] = " ".join(rest[1:4]) if len(rest) > 1 else "iam"
        # service-accounts create|delete
        if len(rest) >= 3 and rest[1] == "service-accounts":
            out["action"] = rest[2]
            if len(rest) > 3 and not rest[3].startswith("-"):
                out["resource"] = rest[3]
        if "add-iam-policy-binding" in rest:
            out["action"] = "add-iam-policy-binding"
        if "remove-iam-policy-binding" in rest:
            out["action"] = "remove-iam-policy-binding"
    elif rest[0] == "compute" and len(rest) > 1 and rest[1] == "instances":
        out["family"] = "compute"
        out["action"] = rest[2] if len(rest) > 2 else "instances"
        if len(rest) > 3 and not rest[3].startswith("-"):
            out["resource"] = rest[3]
    elif rest[0] == "storage" or (rest[0] == "alpha" and len(rest) > 1 and rest[1] == "storage"):
        out["family"] = "gcs"
        out["action"] = " ".join(rest[1:3])
    elif rest[0] == "bq":
        # rare: gcloud bq
        out["family"] = "bigquery"
        out["action"] = rest[1] if len(rest) > 1 else "bq"

elif base == "bq":
    out["family"] = "bigquery"
    rest = argv[1:]
    # flags then subcommand
    i = 0
    while i < len(rest) and rest[i].startswith("-"):
        i += 1
    sub = rest[i] if i < len(rest) else ""
    out["action"] = sub or "bq"
    # resource often last non-flag
    for a in reversed(rest):
        if not a.startswith("-") and a != sub and ":" in a or (a.count(".") >= 1 and a != sub):
            if a not in ("rm", "mk", "cp", "query", "load", "show", "ls", "update"):
                out["resource"] = a
                break
    if sub == "rm":
        out["action"] = "rm"
        # find table id
        for a in rest[i+1:]:
            if not a.startswith("-"):
                out["resource"] = a
                break
    elif sub == "mk":
        out["action"] = "mk"
        for a in rest[i+1:]:
            if not a.startswith("-"):
                out["resource"] = a
                break
    elif sub == "query":
        out["action"] = "query"
        sql = find_flag(rest, "--") or ""
        # positional SQL sometimes
        for a in rest[i+1:]:
            if not a.startswith("-"):
                out["details"]["sql_preview"] = a[:200]
                break
    elif sub == "cp":
        out["action"] = "cp"
    elif sub == "load":
        out["action"] = "load"

elif base == "terraform" or base == "tofu":
    out["family"] = "terraform"
    rest = argv[1:]
    i = 0
    while i < len(rest) and rest[i].startswith("-"):
        i += 1
    out["action"] = rest[i] if i < len(rest) else "terraform"
    state = find_flag(argv, "-state")
    if state:
        out["details"]["state"] = state

elif base == "gsutil":
    out["family"] = "gcs"
    rest = argv[1:]
    out["action"] = rest[0] if rest else "gsutil"
    if rest and rest[0] in ("mb", "rb", "rm", "cp", "mv"):
        for a in rest[1:]:
            if a.startswith("gs://"):
                out["resource"] = a
                break

print(json.dumps(out))
' "$@"
}

# Human one-liner from classification JSON
gcpctx_classify_summary() {
  local json="$1"
  python3 -c '
import json, sys
c = json.loads(sys.argv[1])
print("{family}/{action} resource={resource}".format(**{k: c.get(k,"") for k in ("family","action","resource")}))
' "$json"
}
