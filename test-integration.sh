#!/bin/bash

# Integration Test Script for CSV Processing System
# This script tests all components of the system

echo "================================================"
echo "CSV Processing System - Integration Test"
echo "================================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test results
TESTS_PASSED=0
TESTS_FAILED=0

test_step() {
    echo -e "${YELLOW}➤ $1${NC}"
}

test_success() {
    echo -e "${GREEN}✓ $1${NC}"
    ((TESTS_PASSED++))
}

test_failure() {
    echo -e "${RED}✗ $1${NC}"
    ((TESTS_FAILED++))
}

# 1. Test Rust Build
test_step "Testing Rust build..."
if cargo build 2>&1 | grep -q "Finished"; then
    test_success "Rust build successful"
else
    test_failure "Rust build failed"
fi

# 2. Test Rust CSV Processor
test_step "Testing Rust CSV processor module..."
if cargo test csv_processor 2>&1 | grep -q "test result: ok"; then
    test_success "CSV processor tests passed"
else
    test_failure "CSV processor tests failed"
fi

# 3. Check Node.js installation
test_step "Checking Node.js installation..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    test_success "Node.js installed: $NODE_VERSION"
else
    test_failure "Node.js not installed"
    exit 1
fi

# 4. Install Backend Dependencies
test_step "Installing backend dependencies..."
cd backend
if [ -d "node_modules" ]; then
    test_success "Backend dependencies already installed"
elif npm install 2>&1 > /dev/null; then
    test_success "Backend dependencies installed"
else
    test_failure "Failed to install backend dependencies"
fi
cd ..

# 5. Install Frontend Dependencies
test_step "Installing frontend dependencies..."
cd frontend
if [ -d "node_modules" ]; then
    test_success "Frontend dependencies already installed"
elif npm install 2>&1 > /dev/null; then
    test_success "Frontend dependencies installed"
else
    test_failure "Failed to install frontend dependencies"
fi
cd ..

# 6. Start Backend Server
test_step "Starting backend server..."
cd backend
node src/index.js > /tmp/backend.log 2>&1 &
BACKEND_PID=$!
cd ..
sleep 3

if ps -p $BACKEND_PID > /dev/null; then
    test_success "Backend server started (PID: $BACKEND_PID)"
else
    test_failure "Backend server failed to start"
    cat /tmp/backend.log
    exit 1
fi

# 7. Test Health Endpoint
test_step "Testing health endpoint..."
HEALTH_RESPONSE=$(curl -s http://localhost:3001/mcp/health)
if echo "$HEALTH_RESPONSE" | grep -q "healthy"; then
    test_success "Health endpoint responding"
else
    test_failure "Health endpoint not responding"
fi

# 8. Test Capabilities Endpoint
test_step "Testing capabilities endpoint..."
CAPABILITIES_RESPONSE=$(curl -s http://localhost:3001/mcp/capabilities)
if echo "$CAPABILITIES_RESPONSE" | grep -q "csv_processing"; then
    test_success "Capabilities endpoint responding"
else
    test_failure "Capabilities endpoint not responding"
fi

# 9. Test CSV Upload
test_step "Testing CSV file upload..."
UPLOAD_RESPONSE=$(curl -s -X POST http://localhost:3001/mcp/csv/upload -F "file=@sample-data.csv")
if echo "$UPLOAD_RESPONSE" | grep -q "success.*true"; then
    FILE_ID=$(echo "$UPLOAD_RESPONSE" | grep -o '"id":"[^"]*"' | cut -d'"' -f4)
    test_success "CSV file uploaded successfully (ID: $FILE_ID)"
else
    test_failure "CSV file upload failed"
fi

# 10. Test File List
test_step "Testing file list endpoint..."
LIST_RESPONSE=$(curl -s http://localhost:3001/mcp/csv/list)
if echo "$LIST_RESPONSE" | grep -q "files"; then
    FILE_COUNT=$(echo "$LIST_RESPONSE" | grep -o '"filename"' | wc -l)
    test_success "File list retrieved ($FILE_COUNT files)"
else
    test_failure "File list retrieval failed"
fi

# 11. Test File Processing
if [ ! -z "$FILE_ID" ]; then
    test_step "Testing CSV file processing..."
    PROCESS_RESPONSE=$(curl -s -X POST http://localhost:3001/mcp/csv/${FILE_ID}/process)
    if echo "$PROCESS_RESPONSE" | grep -q "processedRecords"; then
        test_success "CSV file processed successfully"
    else
        test_failure "CSV file processing failed"
    fi
fi

# 12. Test File Retrieval
if [ ! -z "$FILE_ID" ]; then
    test_step "Testing file data retrieval..."
    DATA_RESPONSE=$(curl -s http://localhost:3001/mcp/csv/${FILE_ID})
    if echo "$DATA_RESPONSE" | grep -q "records"; then
        RECORD_COUNT=$(echo "$DATA_RESPONSE" | grep -o '"id":' | wc -l)
        test_success "File data retrieved ($RECORD_COUNT records)"
    else
        test_failure "File data retrieval failed"
    fi
fi

# 13. Test File Deletion
if [ ! -z "$FILE_ID" ]; then
    test_step "Testing file deletion..."
    DELETE_RESPONSE=$(curl -s -X DELETE http://localhost:3001/mcp/csv/${FILE_ID})
    if echo "$DELETE_RESPONSE" | grep -q "success.*true"; then
        test_success "File deleted successfully"
    else
        test_failure "File deletion failed"
    fi
fi

# 14. Test Frontend Files
test_step "Checking frontend files..."
if [ -f "frontend/public/index.html" ]; then
    test_success "Frontend HTML file exists"
else
    test_failure "Frontend HTML file missing"
fi

# 15. Test Documentation
test_step "Checking documentation..."
if [ -f "CSV_PROCESSING.md" ] && [ -f "QUICK_REFERENCE.md" ] && [ -f "ARCHITECTURE.md" ]; then
    test_success "All documentation files present"
else
    test_failure "Some documentation files missing"
fi

# Cleanup
test_step "Cleaning up..."
kill $BACKEND_PID 2>/dev/null || true
wait $BACKEND_PID 2>/dev/null || true
test_success "Backend server stopped"

# Summary
echo ""
echo "================================================"
echo "Test Summary"
echo "================================================"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    echo ""
    echo "The CSV processing system is fully functional."
    echo "To start the system, run: ./start-csv-system.sh"
    exit 0
else
    echo -e "${RED}✗ Some tests failed!${NC}"
    echo "Please review the errors above."
    exit 1
fi
