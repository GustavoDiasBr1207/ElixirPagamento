#!/usr/bin/env bash

# Colorize output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

tree -L 3 -I 'node_modules|_build|deps|.git' \
  --charset ascii \
  -C "${@:-.}"

# Print summary
echo
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  PhoenixPay - Project Structure Summary${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"

find lib -name "*.ex" | wc -l | xargs echo -e "${YELLOW}Elixir files:${NC}"
find priv/repo/migrations -name "*.exs" | wc -l | xargs echo -e "${YELLOW}Migrations:${NC}"

echo
echo -e "${YELLOW}📚 Documentation:${NC}"
echo "  • README.md (Project overview + API)"
echo "  • ARCHITECTURE.md (Detailed structure)"
echo "  • GETTING_STARTED.md (Setup guide)"
echo "  • INTERVIEW_GUIDE.md (Presentation tips)"
echo
