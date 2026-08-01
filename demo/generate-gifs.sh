#!/usr/bin/env bash
# Generate all demo GIFs using the scenario scripts

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCENARIOS_DIR="$SCRIPT_DIR/scenarios"
GIFS_DIR="$SCRIPT_DIR/gifs"

mkdir -p "$GIFS_DIR"

echo "╔════════════════════════════════════════════╗"
echo "║  gcpctx Demo GIF Generator                ║"
echo "╚════════════════════════════════════════════╝"
echo ""

# Check for required tools
if ! command -v asciinema >/dev/null 2>&1; then
    echo "⚠️  asciinema not found. Install with:"
    echo "   brew install asciinema"
    echo "   or: pip install asciinema"
    exit 1
fi

echo "✓ asciinema found"
echo ""

# Record each scenario
for scenario in "$SCENARIOS_DIR"/*.sh; do
    basename="$(basename "$scenario" .sh)"
    cast_file="$GIFS_DIR/${basename}.cast"
    
    echo "🎬 Recording: $basename"
    
    # Make executable
    chmod +x "$scenario"
    
    # Record with asciinema
    asciinema rec "$cast_file" -c "bash $scenario" --overwrite
    
    echo "✓ Saved: $cast_file"
    echo ""
done

echo ""
echo "✅ All scenarios recorded!"
echo ""
echo "Next steps:"
echo "  1. Install agg: cargo install --git https://github.com/asciinema/agg"
echo "  2. Convert to GIF: agg demo/gifs/01-quick-switch.cast demo/gifs/01-quick-switch.gif"
echo "  3. Or use vhs: vhs demo/vhs/01-quick-switch.tape"
echo ""
