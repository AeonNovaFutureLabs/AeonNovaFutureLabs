#!/bin/bash
# ----------------------------------------------------------------------------
# File: setup.sh
# Location: /Volumes/mattstack/VSCode/AeonNovaFutureLabs/scripts/
#
# Purpose: Setup script for chat scraper and dependencies
# Security Level: Confidential
# Owner: Infrastructure Team
# Version: 1.0
# Last Modified: 2025-02-08
# ----------------------------------------------------------------------------

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}Setting up Chat Scraper Component...${NC}"

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo -e "\n${YELLOW}Creating Python virtual environment...${NC}"
    python3 -m venv venv
fi

# Activate virtual environment
echo -e "\n${YELLOW}Activating virtual environment...${NC}"
source venv/bin/activate

# Verify Python dependencies
echo -e "\n${YELLOW}Verifying Python dependencies...${NC}"
python3 scripts/verify_dependencies.py

# Install Node.js dependencies
echo -e "\n${YELLOW}Installing Node.js dependencies...${NC}"
cd ai_components/scraper
npm install

# Build TypeScript
echo -e "\n${YELLOW}Building TypeScript...${NC}"
npm run build

# Run tests
echo -e "\n${YELLOW}Running tests...${NC}"
npm test

# Create necessary directories
echo -e "\n${YELLOW}Creating data directories...${NC}"
mkdir -p data/chat_archive/content

echo -e "\n${GREEN}Setup completed successfully!${NC}"
echo -e "\nTo start the chat scraper:"
echo -e "1. Activate the virtual environment: ${YELLOW}source venv/bin/activate${NC}"
echo -e "2. Run the scraper: ${YELLOW}cd ai_components/scraper && npm start${NC}"
echo -e "\nTo run tests:"
echo -e "1. Python tests: ${YELLOW}python -m pytest${NC}"
echo -e "2. TypeScript tests: ${YELLOW}cd ai_components/scraper && npm test${NC}"