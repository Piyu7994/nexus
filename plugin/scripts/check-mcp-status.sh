#!/bin/bash
# Check if mcp-remote and node are available
if ! command -v node &> /dev/null; then
    echo "ERROR: Node.js is not installed. Required v18+."
    exit 1
fi

NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo "ERROR: Node.js v18+ required. Found v$(node -v)"
    exit 1
fi

echo "OK: Node.js $(node -v) found"
