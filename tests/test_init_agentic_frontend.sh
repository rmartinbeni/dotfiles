#!/bin/bash
set -euo pipefail

echo "Running test for init-agentic-frontend..."

# Create a temporary directory for testing
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT

# Copy the script to test into a temporary bin directory and add it to PATH
MOCK_BIN_DIR=$(mktemp -d)
trap 'rm -rf "$MOCK_BIN_DIR" "$TEST_DIR"' EXIT

cp dot_local/bin/init-agentic-frontend "$MOCK_BIN_DIR/"
chmod +x "$MOCK_BIN_DIR/init-agentic-frontend"

# Mock npm and npx
cat << 'EOF' > "$MOCK_BIN_DIR/npm"
#!/bin/bash
if [ "$1" = "init" ]; then
    echo "{}" > package.json
elif [ "$1" = "install" ]; then
    # Fake install
    exit 0
elif [ "$1" = "pkg" ] && [ "$2" = "set" ]; then
    # Handle "npm pkg set path=value"
    # Example: npm pkg set scripts.lint="eslint ."
    keyval="$3"
    key="${keyval%%=*}"
    val="${keyval#*=}"

    # Simple JSON manipulation using jq
    jq_script=".\"${key}\" = ${val}"

    # Handle nested keys if needed (very simple implementation for tests)
    # The tool sets:
    # scripts.lint
    # scripts.format
    # lint-staged."*.{js,ts,jsx,tsx}"
    # lint-staged."*.{json,md}"

    # We will just parse these specific formats for the test using jq
    if [[ "$key" == scripts.* ]]; then
        script_name="${key#scripts.}"
        jq ".scripts.\"${script_name}\" = \"${val}\"" package.json > package.json.tmp && mv package.json.tmp package.json
    elif [[ "$key" == lint-staged.* ]]; then
        glob_name="${key#lint-staged.}"
        # Remove quotes from val before putting in JSON
        val_unquoted=$(echo "$val" | sed 's/^"//' | sed 's/"$//')
        # We ensure lint-staged object exists
        if ! jq -e '.["lint-staged"]' package.json >/dev/null 2>&1; then
           jq '. + {"lint-staged": {}}' package.json > package.json.tmp && mv package.json.tmp package.json
        fi
        jq ".[\"lint-staged\"][\"${glob_name}\"] = \"${val_unquoted}\"" package.json > package.json.tmp && mv package.json.tmp package.json
    fi
fi
EOF
chmod +x "$MOCK_BIN_DIR/npm"

cat << 'EOF' > "$MOCK_BIN_DIR/npx"
#!/bin/bash
if [ "$1" = "husky" ] && [ "$2" = "init" ]; then
    mkdir -p .husky
fi
EOF
chmod +x "$MOCK_BIN_DIR/npx"

# Prepend MOCK_BIN_DIR to PATH
export PATH="$MOCK_BIN_DIR:$PATH"

# Go to test directory
cd "$TEST_DIR"

# Run the script
init-agentic-frontend

# Assertions
echo "Verifying created files..."

if [ ! -f package.json ]; then
    echo "ERROR: package.json not created."
    exit 1
fi

if [ ! -f .prettierrc ]; then
    echo "ERROR: .prettierrc not created."
    exit 1
fi

if [ ! -f .eslintrc.js ]; then
    echo "ERROR: .eslintrc.js not created."
    exit 1
fi

if [ ! -f .husky/pre-commit ]; then
    echo "ERROR: .husky/pre-commit not created."
    exit 1
fi

if [ ! -f tsconfig.json ]; then
    echo "ERROR: tsconfig.json not created."
    exit 1
fi

# Check package.json contents
echo "Checking package.json updates..."
LINT_SCRIPT=$(jq -r '.scripts.lint' package.json)
if [ "$LINT_SCRIPT" != "eslint ." ]; then
    echo "ERROR: scripts.lint not set correctly (got $LINT_SCRIPT)."
    exit 1
fi

FORMAT_SCRIPT=$(jq -r '.scripts.format' package.json)
if [ "$FORMAT_SCRIPT" != "prettier --write ." ]; then
    echo "ERROR: scripts.format not set correctly (got $FORMAT_SCRIPT)."
    exit 1
fi

LINT_STAGED_TS=$(jq -r '.["lint-staged"]["*.{js,ts,jsx,tsx}"]' package.json)
if [ "$LINT_STAGED_TS" != "eslint --fix" ]; then
    echo "ERROR: lint-staged config not set correctly (got $LINT_STAGED_TS)."
    exit 1
fi

echo "✅ All tests passed successfully!"
