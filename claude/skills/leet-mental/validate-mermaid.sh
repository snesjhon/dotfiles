#!/bin/bash

# Validate all mermaid charts in a markdown file
# Usage: ./validate-mermaid.sh <markdown-file>

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <markdown-file>"
    echo "Example: $0 mental-model.md"
    exit 1
fi

MARKDOWN_FILE="$1"

if [ ! -f "$MARKDOWN_FILE" ]; then
    echo "Error: File not found: $MARKDOWN_FILE"
    exit 1
fi

# Check if mmdc is installed
if ! command -v mmdc &> /dev/null; then
    echo "Error: mmdc not found. Install with: npm install -g @mermaid-js/mermaid-cli"
    exit 1
fi

echo "Validating mermaid charts in: $MARKDOWN_FILE"
echo ""

# Create temp directory for extracted charts
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Extract mermaid blocks
CHART_COUNT=0
IN_MERMAID=0
CURRENT_CHART=""

while IFS= read -r line; do
    if [[ "$line" == '```mermaid' ]]; then
        IN_MERMAID=1
        CHART_COUNT=$((CHART_COUNT + 1))
        CURRENT_CHART="$TEMP_DIR/chart_$CHART_COUNT.mmd"
        > "$CURRENT_CHART"  # Create empty file
    elif [[ "$line" == '```' ]] && [ $IN_MERMAID -eq 1 ]; then
        IN_MERMAID=0
    elif [ $IN_MERMAID -eq 1 ]; then
        echo "$line" >> "$CURRENT_CHART"
    fi
done < "$MARKDOWN_FILE"

if [ $CHART_COUNT -eq 0 ]; then
    echo "⚠️  No mermaid charts found in file"
    exit 0
fi

echo "Found $CHART_COUNT mermaid chart(s)"
echo ""

# Validate each chart
ALL_VALID=1
for i in $(seq 1 $CHART_COUNT); do
    CHART_FILE="$TEMP_DIR/chart_$i.mmd"
    OUTPUT_FILE="$TEMP_DIR/chart_$i.svg"
    echo "Validating chart $i..."

    if mmdc -i "$CHART_FILE" -o "$OUTPUT_FILE" 2>&1 > /dev/null; then
        echo "✓ Chart $i: Valid"
    else
        echo "✗ Chart $i: INVALID"
        echo "  Error details:"
        mmdc -i "$CHART_FILE" -o "$OUTPUT_FILE" 2>&1 | sed 's/^/  /'
        ALL_VALID=0
    fi
    echo ""
done

if [ $ALL_VALID -eq 1 ]; then
    echo "✓ All charts are valid!"
    exit 0
else
    echo "✗ Some charts have errors. Please fix them."
    exit 1
fi
