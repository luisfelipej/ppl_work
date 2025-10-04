#!/bin/bash

# PplWork API Testing Script
# Automatically tests all REST API endpoints

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Base URL
BASE_URL="http://localhost:4000"

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Helper functions
print_header() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${BLUE}$1${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

print_test() {
    echo -e "${YELLOW}▶${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
    ((TESTS_PASSED++))
}

print_error() {
    echo -e "${RED}✗${NC} $1"
    ((TESTS_FAILED++))
}

check_response() {
    local response=$1
    local expected_key=$2
    local test_name=$3

    if echo "$response" | jq -e ".data.$expected_key" > /dev/null 2>&1; then
        print_success "$test_name"
        return 0
    elif echo "$response" | jq -e ".data" > /dev/null 2>&1; then
        print_success "$test_name"
        return 0
    else
        print_error "$test_name"
        echo "  Response: $response"
        return 1
    fi
}

# Start tests
clear
echo ""
echo "╔═══════════════════════════════════════════════════╗"
echo "║                                                   ║"
echo "║     🧪 PplWork API Testing Suite                ║"
echo "║                                                   ║"
echo "╚═══════════════════════════════════════════════════╝"
echo ""

# Check if server is running
print_header "Checking Server Status"
print_test "Testing connection to $BASE_URL..."

if curl -s "$BASE_URL" > /dev/null 2>&1; then
    print_success "Server is running"
else
    print_error "Server is NOT running"
    echo ""
    echo -e "${RED}Please start the server first:${NC}"
    echo "  make server"
    echo ""
    exit 1
fi

# Test 1: User Registration
print_header "1. User Registration"

print_test "Registering new user..."
REGISTER_RESPONSE=$(curl -s -X POST "$BASE_URL/api/users/register" \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "testscript@example.com",
      "username": "testscript",
      "password": "Password123"
    }
  }')

if check_response "$REGISTER_RESPONSE" "id" "User registration"; then
    USER_ID=$(echo "$REGISTER_RESPONSE" | jq -r '.data.id')
    echo "  User ID: $USER_ID"
fi

# Test invalid email
print_test "Testing invalid email validation..."
INVALID_EMAIL=$(curl -s -X POST "$BASE_URL/api/users/register" \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "invalid-email",
      "username": "testinvalid",
      "password": "Password123"
    }
  }')

if echo "$INVALID_EMAIL" | jq -e '.errors.email' > /dev/null 2>&1; then
    print_success "Email validation works"
else
    print_error "Email validation failed"
fi

# Test 2: User Login
print_header "2. User Authentication"

print_test "Login with correct credentials..."
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/users/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "alice@pplwork.com",
    "password": "Password123"
  }')

if check_response "$LOGIN_RESPONSE" "id" "User login with correct credentials"; then
    ALICE_ID=$(echo "$LOGIN_RESPONSE" | jq -r '.data.id')
    echo "  Alice ID: $ALICE_ID"
fi

print_test "Login with wrong password..."
WRONG_LOGIN=$(curl -s -X POST "$BASE_URL/api/users/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "alice@pplwork.com",
    "password": "WrongPassword"
  }')

if echo "$WRONG_LOGIN" | jq -e '.error' > /dev/null 2>&1; then
    print_success "Wrong password rejected correctly"
else
    print_error "Wrong password validation failed"
fi

# Test 3: Get User
print_header "3. Get User Information"

print_test "Getting user by ID..."
GET_USER=$(curl -s "$BASE_URL/api/users/$ALICE_ID")

if check_response "$GET_USER" "username" "Get user by ID"; then
    USERNAME=$(echo "$GET_USER" | jq -r '.data.username')
    echo "  Username: $USERNAME"
fi

# Test 4: List Spaces
print_header "4. List Spaces"

print_test "Getting public spaces..."
SPACES=$(curl -s "$BASE_URL/api/spaces")

if echo "$SPACES" | jq -e '.data | length' > /dev/null 2>&1; then
    SPACE_COUNT=$(echo "$SPACES" | jq '.data | length')
    print_success "Listed $SPACE_COUNT public spaces"

    # Get first space ID for later tests
    SPACE_ID=$(echo "$SPACES" | jq -r '.data[0].id')
    echo "  Using space ID: $SPACE_ID"
else
    print_error "Failed to list spaces"
fi

# Test 5: Create Space
print_header "5. Create Space"

print_test "Creating new space..."
CREATE_SPACE=$(curl -s -X POST "$BASE_URL/api/spaces" \
  -H "Content-Type: application/json" \
  -d '{
    "space": {
      "name": "Test Space from Script",
      "width": 50,
      "height": 50,
      "description": "Auto-created by test script",
      "is_public": true,
      "max_occupancy": 20
    }
  }')

if check_response "$CREATE_SPACE" "id" "Space creation"; then
    NEW_SPACE_ID=$(echo "$CREATE_SPACE" | jq -r '.data.id')
    echo "  New space ID: $NEW_SPACE_ID"
fi

# Test invalid space (missing required fields)
print_test "Testing space validation..."
INVALID_SPACE=$(curl -s -X POST "$BASE_URL/api/spaces" \
  -H "Content-Type: application/json" \
  -d '{
    "space": {
      "name": "A"
    }
  }')

if echo "$INVALID_SPACE" | jq -e '.errors' > /dev/null 2>&1; then
    print_success "Space validation works"
else
    print_error "Space validation failed"
fi

# Test 6: Get Space
print_header "6. Get Space Information"

print_test "Getting space by ID..."
GET_SPACE=$(curl -s "$BASE_URL/api/spaces/$SPACE_ID")

if check_response "$GET_SPACE" "name" "Get space by ID"; then
    SPACE_NAME=$(echo "$GET_SPACE" | jq -r '.data.name')
    echo "  Space name: $SPACE_NAME"
fi

# Test 7: Update Space
print_header "7. Update Space"

print_test "Updating space..."
UPDATE_SPACE=$(curl -s -X PUT "$BASE_URL/api/spaces/$NEW_SPACE_ID" \
  -H "Content-Type: application/json" \
  -d '{
    "space": {
      "name": "Updated Test Space",
      "max_occupancy": 30
    }
  }')

if check_response "$UPDATE_SPACE" "id" "Space update"; then
    UPDATED_NAME=$(echo "$UPDATE_SPACE" | jq -r '.data.name')
    echo "  Updated name: $UPDATED_NAME"
fi

# Test 8: Get Space Occupancy
print_header "8. Space Occupancy"

print_test "Getting space occupancy..."
OCCUPANCY=$(curl -s "$BASE_URL/api/spaces/$SPACE_ID/occupancy")

if echo "$OCCUPANCY" | jq -e '.space_id' > /dev/null 2>&1; then
    CURRENT_OCC=$(echo "$OCCUPANCY" | jq -r '.current_occupancy')
    MAX_OCC=$(echo "$OCCUPANCY" | jq -r '.max_occupancy')
    AT_CAPACITY=$(echo "$OCCUPANCY" | jq -r '.at_capacity')
    print_success "Got occupancy info"
    echo "  Current: $CURRENT_OCC / $MAX_OCC"
    echo "  At capacity: $AT_CAPACITY"
else
    print_error "Failed to get occupancy"
fi

# Test 9: Delete Space
print_header "9. Delete Space"

print_test "Deleting test space..."
DELETE_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "$BASE_URL/api/spaces/$NEW_SPACE_ID")

if [ "$DELETE_RESPONSE" = "204" ]; then
    print_success "Space deleted successfully"
else
    print_error "Failed to delete space (HTTP $DELETE_RESPONSE)"
fi

# Verify deletion
print_test "Verifying space was deleted..."
GET_DELETED=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/api/spaces/$NEW_SPACE_ID")

if [ "$GET_DELETED" = "404" ]; then
    print_success "Space no longer exists"
else
    print_error "Space still exists after deletion"
fi

# Test Summary
print_header "Test Summary"

TOTAL_TESTS=$((TESTS_PASSED + TESTS_FAILED))
SUCCESS_RATE=$(awk "BEGIN {printf \"%.1f\", ($TESTS_PASSED/$TOTAL_TESTS)*100}")

echo ""
echo "  Total tests: $TOTAL_TESTS"
echo -e "  ${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "  ${RED}Failed: $TESTS_FAILED${NC}"
echo "  Success rate: $SUCCESS_RATE%"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}╔═══════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                   ║${NC}"
    echo -e "${GREEN}║           ✓ All tests passed! 🎉                 ║${NC}"
    echo -e "${GREEN}║                                                   ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════╝${NC}"
    echo ""
    exit 0
else
    echo -e "${RED}╔═══════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║                                                   ║${NC}"
    echo -e "${RED}║           ✗ Some tests failed                    ║${NC}"
    echo -e "${RED}║                                                   ║${NC}"
    echo -e "${RED}╚═══════════════════════════════════════════════════╝${NC}"
    echo ""
    exit 1
fi
