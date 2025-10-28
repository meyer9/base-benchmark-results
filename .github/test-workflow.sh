#!/bin/bash
# Test script to simulate the GitHub Actions workflow locally
# This helps verify the workflow logic before pushing to GitHub

set -e

echo "🧪 Testing workflow logic locally..."
echo ""

# Create temporary directories
TEST_DIR=$(mktemp -d)
BENCHMARK_DIR="$TEST_DIR/benchmark-repo"
PAGES_DIR="$TEST_DIR/pages"

echo "📁 Test directory: $TEST_DIR"
echo ""

# Check if we're in the right directory
if [ ! -d "results" ]; then
  echo "❌ Error: Must run from repository root"
  exit 1
fi

# Clone the benchmark repository
echo "📦 Cloning benchmark repository..."
git clone https://github.com/base/benchmark.git "$BENCHMARK_DIR" --depth 1
echo "✓ Benchmark repository cloned"
echo ""

# Check if report directory exists
if [ ! -d "$BENCHMARK_DIR/report" ]; then
  echo "❌ Error: benchmark/report directory not found"
  echo "The repository structure may have changed"
  exit 1
fi

# Install npm dependencies
echo "📦 Installing npm dependencies..."
cd "$BENCHMARK_DIR/report"
npm install
cd - > /dev/null
echo "✓ Dependencies installed"
echo ""

# Create pages directory
mkdir -p "$PAGES_DIR"

# Process each result directory
echo "🔄 Processing result directories..."
RESULT_COUNT=0

for result_dir in results/*/; do
  if [ -d "$result_dir" ]; then
    result_name=$(basename "$result_dir")
    echo ""
    echo "  Processing: $result_name"
    
    # Clean output directory
    rm -rf "$BENCHMARK_DIR/output"
    
    # Copy result data
    echo "    → Copying result data..."
    cp -r "$result_dir" "$BENCHMARK_DIR/output"
    
    # Build report
    echo "    → Building report..."
    cd "$BENCHMARK_DIR/report"
    if npm run build > /dev/null 2>&1; then
      echo "    ✓ Build successful"
    else
      echo "    ❌ Build failed for $result_name"
      cd - > /dev/null
      continue
    fi
    cd - > /dev/null
    
    # Copy built files
    echo "    → Copying build artifacts..."
    mkdir -p "$PAGES_DIR/$result_name"
    cp -r "$BENCHMARK_DIR/report/dist"/* "$PAGES_DIR/$result_name/"
    
    echo "    ✓ Completed $result_name"
    RESULT_COUNT=$((RESULT_COUNT + 1))
  fi
done

echo ""
echo "📝 Creating index page..."

# Create index page
cat > "$PAGES_DIR/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Base Benchmark Reports</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
      max-width: 800px;
      margin: 0 auto;
      padding: 2rem;
      line-height: 1.6;
      color: #333;
    }
    h1 {
      border-bottom: 2px solid #0066cc;
      padding-bottom: 0.5rem;
    }
    .report-list {
      list-style: none;
      padding: 0;
    }
    .report-list li {
      margin: 1rem 0;
    }
    .report-list a {
      display: block;
      padding: 1rem;
      background: #f5f5f5;
      border-radius: 8px;
      text-decoration: none;
      color: #0066cc;
      transition: background 0.2s;
    }
    .report-list a:hover {
      background: #e0e0e0;
    }
    .report-name {
      font-size: 1.2rem;
      font-weight: 600;
    }
  </style>
</head>
<body>
  <h1>Base Benchmark Reports</h1>
  <p>Select a benchmark report to view:</p>
  <ul class="report-list">
EOF

# Add links for each report
for result_dir in results/*/; do
  if [ -d "$result_dir" ]; then
    result_name=$(basename "$result_dir")
    result_title=$(echo "$result_name" | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')
    echo "    <li><a href=\"./$result_name/\"><span class=\"report-name\">$result_title</span></a></li>" >> "$PAGES_DIR/index.html"
  fi
done

# Close HTML
cat >> "$PAGES_DIR/index.html" << 'EOF'
  </ul>
</body>
</html>
EOF

echo "✓ Index page created"
echo ""

# Summary
echo "✅ Test completed successfully!"
echo ""
echo "📊 Summary:"
echo "  • Processed $RESULT_COUNT result directories"
echo "  • Built pages are in: $PAGES_DIR"
echo ""
echo "🌐 To view locally, run:"
echo "  cd $PAGES_DIR && python3 -m http.server 8000"
echo "  Then open http://localhost:8000"
echo ""
echo "🧹 To clean up test files:"
echo "  rm -rf $TEST_DIR"

