#!/bin/bash

# Generate Flutter test coverage with correct directory paths
# This script fixes the lcov directory path duplication issue

echo "Running Flutter tests with coverage..."
flutter test --coverage

echo "Generating HTML coverage report with correct directory paths..."
genhtml coverage/lcov.info -o coverage/html --prefix $PWD/lib

echo "Coverage report generated successfully!"
echo "Open coverage/html/index.html in your browser to view the report."
