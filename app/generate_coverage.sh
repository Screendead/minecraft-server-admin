#!/bin/bash

# Generate Flutter test coverage with correct directory paths
# This script fixes the lcov directory path duplication issue

echo "Running Flutter tests with coverage..."
flutter test --coverage

echo "Generating HTML coverage report..."
genhtml coverage/lcov.info -o coverage/html

echo "Fixing directory path duplication in HTML files..."
find coverage/html -name "*.html" -exec sed -i '' 's|/lib/models/lib/models|/models|g' {} \;
find coverage/html -name "*.html" -exec sed -i '' 's|/lib/providers/lib/providers|/providers|g' {} \;
find coverage/html -name "*.html" -exec sed -i '' 's|/lib/services/lib/services|/services|g' {} \;
find coverage/html -name "*.html" -exec sed -i '' 's|/lib/utils/lib/utils|/utils|g' {} \;
find coverage/html -name "*.html" -exec sed -i '' 's|models/lib/models|models|g' {} \;
find coverage/html -name "*.html" -exec sed -i '' 's|providers/lib/providers|providers|g' {} \;
find coverage/html -name "*.html" -exec sed -i '' 's|services/lib/services|services|g' {} \;
find coverage/html -name "*.html" -exec sed -i '' 's|utils/lib/utils|utils|g' {} \;

echo "Coverage report generated successfully!"
echo "Open coverage/html/index.html in your browser to view the report."
