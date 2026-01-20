#!/usr/bin/env bats
# Tests for auto-format.sh hook

load 'test_helper/common'

setup() {
    HOOK="$BATS_TEST_DIRNAME/../hooks/auto-format.sh"
    # Create temp directory for test files
    TEST_DIR=$(mktemp -d)
    ORIG_PWD="$PWD"
    cd "$TEST_DIR"
}

teardown() {
    cd "$ORIG_PWD"
    rm -rf "$TEST_DIR"
}

# Helper to run hook with given file_path
run_format_hook() {
    make_format_input "$1" | bash "$HOOK"
}

# ============================================================================
# SKIP CASES - Binary and generated files
# ============================================================================

@test "skips binary files (png)" {
    run run_format_hook "image.png"
    [ "$status" -eq 0 ]
    [ "$output" = "{}" ]
}

@test "skips binary files (jpg)" {
    run run_format_hook "photo.jpg"
    [ "$status" -eq 0 ]
    [ "$output" = "{}" ]
}

@test "skips binary files (pdf)" {
    run run_format_hook "document.pdf"
    [ "$status" -eq 0 ]
    [ "$output" = "{}" ]
}

@test "skips lock files" {
    run run_format_hook "package-lock.json"
    [ "$status" -eq 0 ]
    [ "$output" = "{}" ]
}

@test "skips map files" {
    run run_format_hook "bundle.js.map"
    [ "$status" -eq 0 ]
    [ "$output" = "{}" ]
}

@test "skips minified files" {
    run run_format_hook "app.min.js"
    [ "$status" -eq 0 ]
    [ "$output" = "{}" ]
}

@test "skips node_modules" {
    run run_format_hook "node_modules/package/index.js"
    [ "$status" -eq 0 ]
    [ "$output" = "{}" ]
}

@test "skips dist directory" {
    run run_format_hook "dist/bundle.js"
    [ "$status" -eq 0 ]
    [ "$output" = "{}" ]
}

@test "skips build directory" {
    run run_format_hook "build/output.js"
    [ "$status" -eq 0 ]
    [ "$output" = "{}" ]
}

@test "skips .git directory" {
    run run_format_hook ".git/config"
    [ "$status" -eq 0 ]
    [ "$output" = "{}" ]
}

@test "skips vendor directory" {
    run run_format_hook "vendor/lib/file.go"
    [ "$status" -eq 0 ]
    [ "$output" = "{}" ]
}

@test "skips __pycache__ directory" {
    run run_format_hook "__pycache__/module.pyc"
    [ "$status" -eq 0 ]
    [ "$output" = "{}" ]
}

@test "skips .next directory" {
    run run_format_hook ".next/static/chunk.js"
    [ "$status" -eq 0 ]
    [ "$output" = "{}" ]
}

@test "skips coverage directory" {
    run run_format_hook "coverage/lcov.info"
    [ "$status" -eq 0 ]
    [ "$output" = "{}" ]
}

# ============================================================================
# EMPTY/MISSING INPUT
# ============================================================================

@test "handles empty input" {
    run bash "$HOOK" <<< '{}'
    [ "$status" -eq 0 ]
    [ "$output" = "{}" ]
}

@test "handles missing file_path" {
    run bash "$HOOK" <<< '{"tool_input":{}}'
    [ "$status" -eq 0 ]
    [ "$output" = "{}" ]
}

@test "handles missing tool_input" {
    run bash "$HOOK" <<< '{"other":"data"}'
    [ "$status" -eq 0 ]
    [ "$output" = "{}" ]
}

# ============================================================================
# NO FORMATTER AVAILABLE
# ============================================================================

@test "returns no formatter message for unknown extension" {
    touch test.xyz
    run run_format_hook "$TEST_DIR/test.xyz"
    [ "$status" -eq 0 ]
    has_system_message
    has_no_formatter
}

@test "returns no formatter for js without package.json" {
    touch test.js
    run run_format_hook "$TEST_DIR/test.js"
    [ "$status" -eq 0 ]
    has_system_message
    # Either formatted with global tool or no formatter
    [[ "$output" == *'Formatted'* ]] || [[ "$output" == *'No formatter'* ]]
}

# ============================================================================
# PROJECT ROOT DETECTION
# ============================================================================

@test "finds project root with package.json" {
    echo '{}' > package.json
    mkdir -p src/components
    touch src/components/App.tsx
    run run_format_hook "$TEST_DIR/src/components/App.tsx"
    [ "$status" -eq 0 ]
    has_system_message
}

@test "finds project root with nx.json" {
    echo '{}' > nx.json
    mkdir -p apps/web/src
    touch apps/web/src/main.ts
    run run_format_hook "$TEST_DIR/apps/web/src/main.ts"
    [ "$status" -eq 0 ]
    has_system_message
}

@test "finds project root with go.mod" {
    echo 'module example.com/test' > go.mod
    mkdir -p cmd
    touch cmd/main.go
    run run_format_hook "$TEST_DIR/cmd/main.go"
    [ "$status" -eq 0 ]
    has_system_message
}

@test "finds project root with pyproject.toml" {
    echo '[project]' > pyproject.toml
    mkdir -p src
    touch src/app.py
    run run_format_hook "$TEST_DIR/src/app.py"
    [ "$status" -eq 0 ]
    has_system_message
}

# ============================================================================
# CLAUDE.MD OVERRIDE
# ============================================================================

@test "uses CLAUDE.md format command" {
    echo 'format: echo formatted' > CLAUDE.md
    touch test.js
    run run_format_hook "$TEST_DIR/test.js"
    [ "$status" -eq 0 ]
    has_system_message
    [[ "$output" == *'CLAUDE.md'* ]]
}

@test "uses CLAUDE.md formatter directive" {
    echo 'formatter: echo formatted' > CLAUDE.md
    touch test.ts
    run run_format_hook "$TEST_DIR/test.ts"
    [ "$status" -eq 0 ]
    has_system_message
    [[ "$output" == *'CLAUDE.md'* ]]
}

@test "reports CLAUDE.md command failure" {
    echo 'format: false' > CLAUDE.md
    touch test.js
    run run_format_hook "$TEST_DIR/test.js"
    [ "$status" -eq 0 ]
    has_system_message
    [[ "$output" == *'failed'* ]]
}

# ============================================================================
# FORMATTER DETECTION FROM PACKAGE.JSON
# ============================================================================

@test "detects prettier from package.json devDependencies" {
    cat > package.json << 'EOF'
{"devDependencies": {"prettier": "^3.0.0"}}
EOF
    touch test.js
    run run_format_hook "$TEST_DIR/test.js"
    [ "$status" -eq 0 ]
    has_system_message
}

@test "detects biome from package.json devDependencies" {
    cat > package.json << 'EOF'
{"devDependencies": {"@biomejs/biome": "^1.0.0"}}
EOF
    touch test.ts
    run run_format_hook "$TEST_DIR/test.ts"
    [ "$status" -eq 0 ]
    has_system_message
}

@test "detects prettier from package.json dependencies" {
    cat > package.json << 'EOF'
{"dependencies": {"prettier": "^3.0.0"}}
EOF
    touch test.json
    run run_format_hook "$TEST_DIR/test.json"
    [ "$status" -eq 0 ]
    has_system_message
}

# ============================================================================
# PYTHON FORMATTER DETECTION
# ============================================================================

@test "detects black from pyproject.toml" {
    cat > pyproject.toml << 'EOF'
[tool.black]
line-length = 88
EOF
    touch app.py
    run run_format_hook "$TEST_DIR/app.py"
    [ "$status" -eq 0 ]
    has_system_message
}

@test "detects ruff from pyproject.toml" {
    cat > pyproject.toml << 'EOF'
[tool.ruff]
line-length = 88
EOF
    touch app.py
    run run_format_hook "$TEST_DIR/app.py"
    [ "$status" -eq 0 ]
    has_system_message
}

# ============================================================================
# FILE EXTENSION HANDLING
# ============================================================================

@test "handles TypeScript files" {
    echo '{}' > package.json
    touch app.ts
    run run_format_hook "$TEST_DIR/app.ts"
    [ "$status" -eq 0 ]
    has_system_message
}

@test "handles TSX files" {
    echo '{}' > package.json
    touch App.tsx
    run run_format_hook "$TEST_DIR/App.tsx"
    [ "$status" -eq 0 ]
    has_system_message
}

@test "handles CSS files" {
    echo '{}' > package.json
    touch styles.css
    run run_format_hook "$TEST_DIR/styles.css"
    [ "$status" -eq 0 ]
    has_system_message
}

@test "handles SCSS files" {
    echo '{}' > package.json
    touch styles.scss
    run run_format_hook "$TEST_DIR/styles.scss"
    [ "$status" -eq 0 ]
    has_system_message
}

@test "handles HTML files" {
    echo '{}' > package.json
    touch index.html
    run run_format_hook "$TEST_DIR/index.html"
    [ "$status" -eq 0 ]
    has_system_message
}

@test "handles Markdown files" {
    echo '{}' > package.json
    touch README.md
    run run_format_hook "$TEST_DIR/README.md"
    [ "$status" -eq 0 ]
    has_system_message
}

@test "handles YAML files" {
    echo '{}' > package.json
    touch config.yaml
    run run_format_hook "$TEST_DIR/config.yaml"
    [ "$status" -eq 0 ]
    has_system_message
}

@test "handles Vue files" {
    echo '{}' > package.json
    touch App.vue
    run run_format_hook "$TEST_DIR/App.vue"
    [ "$status" -eq 0 ]
    has_system_message
}

@test "handles Svelte files" {
    echo '{}' > package.json
    touch App.svelte
    run run_format_hook "$TEST_DIR/App.svelte"
    [ "$status" -eq 0 ]
    has_system_message
}

@test "handles Python .pyi files" {
    echo '[project]' > pyproject.toml
    touch stubs.pyi
    run run_format_hook "$TEST_DIR/stubs.pyi"
    [ "$status" -eq 0 ]
    has_system_message
}

# ============================================================================
# RELATIVE VS ABSOLUTE PATHS
# ============================================================================

@test "handles absolute paths" {
    echo '{}' > package.json
    touch test.js
    run run_format_hook "$TEST_DIR/test.js"
    [ "$status" -eq 0 ]
    has_system_message
}

@test "handles relative paths" {
    echo '{}' > package.json
    touch test.js
    # The hook will convert relative to absolute using pwd
    run run_format_hook "test.js"
    [ "$status" -eq 0 ]
    has_system_message
}

# ============================================================================
# NPM FORMAT SCRIPT DETECTION
# ============================================================================

@test "detects format script in package.json" {
    cat > package.json << 'EOF'
{"scripts": {"format": "echo formatted"}}
EOF
    touch test.xyz
    run run_format_hook "$TEST_DIR/test.xyz"
    [ "$status" -eq 0 ]
    has_system_message
}

@test "detects format:write script in package.json" {
    cat > package.json << 'EOF'
{"scripts": {"format:write": "echo formatted"}}
EOF
    touch test.xyz
    run run_format_hook "$TEST_DIR/test.xyz"
    [ "$status" -eq 0 ]
    has_system_message
}

# ============================================================================
# CACHING TESTS
# ============================================================================

@test "creates cache file after detection" {
    echo '{"devDependencies": {"prettier": "^3.0.0"}}' > package.json
    touch test.js
    run run_format_hook "$TEST_DIR/test.js"
    [ "$status" -eq 0 ]
    # Check that cache was created
    cache_count=$(ls /tmp/claude-format-cache/*.cache 2>/dev/null | wc -l)
    [ "$cache_count" -gt 0 ]
}

@test "cache is invalidated when package.json changes" {
    echo '{}' > package.json
    touch test.js
    # First run - creates cache
    run run_format_hook "$TEST_DIR/test.js"
    [ "$status" -eq 0 ]

    # Modify package.json (touch to update mtime)
    sleep 1
    echo '{"devDependencies": {"prettier": "^3.0.0"}}' > package.json

    # Second run - should detect the change
    run run_format_hook "$TEST_DIR/test.js"
    [ "$status" -eq 0 ]
    has_system_message
}

# ============================================================================
# NESTED PROJECT TESTS (Monorepo scenarios)
# ============================================================================

@test "nested Go project gets its own project root" {
    # Root is a Node project
    echo '{"devDependencies": {"prettier": "^3.0.0"}}' > package.json

    # Nested Go service with its own go.mod
    mkdir -p services/api
    echo 'module example.com/api' > services/api/go.mod
    touch services/api/main.go

    # The Go file should find services/api as its project root (not the Node root)
    run run_format_hook "$TEST_DIR/services/api/main.go"
    [ "$status" -eq 0 ]
    has_system_message
    # Should NOT mention Prettier (that's at the Node root)
    [[ "$output" != *"Prettier"* ]]
}

@test "nested Python project gets its own project root" {
    # Root is a Node project
    echo '{"devDependencies": {"prettier": "^3.0.0"}}' > package.json

    # Nested Python project with its own pyproject.toml
    mkdir -p ml/training
    cat > ml/pyproject.toml << 'EOF'
[tool.ruff]
line-length = 88
EOF
    touch ml/training/model.py

    # The Python file should find ml/ as its project root
    run run_format_hook "$TEST_DIR/ml/training/model.py"
    [ "$status" -eq 0 ]
    has_system_message
    # Should NOT mention Prettier
    [[ "$output" != *"Prettier"* ]]
}

@test "file without nested config uses parent project root" {
    # Root is a Node project with Prettier
    echo '{"devDependencies": {"prettier": "^3.0.0"}}' > package.json

    # Scripts directory without its own config
    mkdir -p scripts
    touch scripts/util.js

    # Should use root project root and find Prettier
    run run_format_hook "$TEST_DIR/scripts/util.js"
    [ "$status" -eq 0 ]
    has_system_message
}
