# shellcheck shell=bash
# Validation helpers — fail closed on unsafe input.

gcpctx_die() { echo "gcpctx: $*" >&2; exit 1; }

# Context names: conservative allowlist (also used as directory names)
gcpctx_validate_context_name() {
  local name="$1"
  if [[ -z "$name" ]]; then
    gcpctx_die "context name is empty"
  fi
  if [[ ${#name} -gt 64 ]]; then
    gcpctx_die "context name too long (max 64)"
  fi
  if [[ "$name" == -* ]]; then
    gcpctx_die "context name must not start with '-'"
  fi
  case "$name" in
    */*|*[\\]*|*..*)
      gcpctx_die "context name must not contain path separators or '..'"
      ;;
  esac
  if [[ ! "$name" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]]; then
    gcpctx_die "invalid context name '$name' (allowed: [A-Za-z0-9._-], start alphanumeric)"
  fi
  # Reject control chars / newlines explicitly
  if [[ "$name" == *$'\n'* || "$name" == *$'\r'* || "$name" == *$'\t'* ]]; then
    gcpctx_die "context name contains control characters"
  fi
}

# GCP project IDs: 6-30 chars, lowercase letter start, lowercase/digit/hyphen
# Also allow longer legacy / org-created IDs that are commonly seen (up to 63)
gcpctx_validate_project_id() {
  local id="$1"
  if [[ -z "$id" ]]; then
    gcpctx_die "project id is empty"
  fi
  if [[ ${#id} -gt 63 ]]; then
    gcpctx_die "project id too long"
  fi
  if [[ "$id" == *$'\n'* || "$id" == *$'\r'* ]]; then
    gcpctx_die "project id contains newline"
  fi
  case "$id" in
    */*|*[\\]*|*\$*|*\;*|*\'*|*\"*|*\\\`*|*\|*|*\(*|*\)*|*\&*|*\<*|\*\>*)
      gcpctx_die "project id contains forbidden characters"
      ;;
  esac
  if [[ ! "$id" =~ ^[a-z][a-z0-9-]{4,62}$ ]]; then
    # Soft fail message: still reject metacharacters above; allow if alphanumeric/hyphen only
    if [[ ! "$id" =~ ^[a-zA-Z0-9][a-zA-Z0-9._-]{0,62}$ ]]; then
      gcpctx_die "invalid project id"
    fi
  fi
}

gcpctx_validate_account() {
  local account="$1"
  if [[ -z "$account" ]]; then
    gcpctx_die "account is empty"
  fi
  if [[ "$account" == *$'\n'* || "$account" == *$'\r'* ]]; then
    gcpctx_die "account contains newline"
  fi
  if [[ ${#account} -gt 256 ]]; then
    gcpctx_die "account too long"
  fi
  # email-ish or service account; reject shell metacharacters
  case "$account" in
    *\$*|*\;*|*\'*|*\"*|*\\\`*|*\|*|*\(*|*\)*|*\&*|*\<*|*\>*|*\\*)
      gcpctx_die "account contains forbidden characters"
      ;;
  esac
}

gcpctx_validate_region() {
  local r="${1:-}"
  [[ -z "$r" ]] && return 0
  if [[ ! "$r" =~ ^[a-z][a-z0-9-]{1,63}$ ]]; then
    gcpctx_die "invalid region"
  fi
}

gcpctx_validate_zone() {
  local z="${1:-}"
  [[ -z "$z" ]] && return 0
  if [[ ! "$z" =~ ^[a-z][a-z0-9-]{1,63}$ ]]; then
    gcpctx_die "invalid zone"
  fi
}
