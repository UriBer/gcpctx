# Shared safe-eval helper for bash and zsh wrappers.
# Only allows allowlisted export/unset lines before eval.
#
# Usage: _gcpctx_safe_eval "$(gcpctx use dev --export)"

_gcpctx_export_name_ok() {
  case "$1" in
    GCPCTX_NAME|GCPCTX_HOME|GOOGLE_APPLICATION_CREDENTIALS|GOOGLE_CLOUD_PROJECT|GCLOUD_PROJECT|GOOGLE_CLOUD_QUOTA_PROJECT|CLOUDSDK_CORE_PROJECT|CLOUDSDK_ACTIVE_CONFIG_NAME)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

_gcpctx_safe_eval() {
  local script="$1"
  local line name rest
  if [ -z "${script}" ]; then
    return 0
  fi
  while IFS= read -r line || [ -n "$line" ]; do
    [ -z "$line" ] && continue
    line="${line%$'\r'}"
    case "$line" in
      \#*) continue ;;
      export\ *)
        rest="${line#export }"
        name="${rest%%=*}"
        # Reject spaces / metacharacters in the name token
        case "$name" in
          *[!A-Za-z0-9_]*|'')
            echo "gcpctx: refusing unsafe export name in: ${line:0:80}" >&2
            return 1
            ;;
        esac
        if ! _gcpctx_export_name_ok "$name"; then
          echo "gcpctx: refusing non-allowlisted export: $name" >&2
          return 1
        fi
        # Must be export NAME=... (assignment), not export NAME alone with junk
        case "$rest" in
          "$name"=*) ;;
          *)
            echo "gcpctx: refusing malformed export line: ${line:0:80}" >&2
            return 1
            ;;
        esac
        ;;
      unset\ *)
        rest="${line#unset }"
        name="${rest%% *}"
        case "$name" in
          *[!A-Za-z0-9_]*|'')
            echo "gcpctx: refusing unsafe unset: ${line:0:80}" >&2
            return 1
            ;;
        esac
        if ! _gcpctx_export_name_ok "$name"; then
          echo "gcpctx: refusing non-allowlisted unset: $name" >&2
          return 1
        fi
        ;;
      *)
        echo "gcpctx: refusing unsafe shell activation line: ${line:0:80}" >&2
        return 1
        ;;
    esac
  done <<EOF
$script
EOF
  eval "$script"
}
