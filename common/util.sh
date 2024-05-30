RED='\033[1;31m'
NC='\033[0m' # No Color
BLUE='\033[1;36m'
PURPLE='\033[1;35m'
ORANGE='\033[0;33m'

# echo -e "${BLUE}INFO:${NC}
# echo -e "${RED}ERROR:${NC}
# echo -e "${ORANGE}WARNING:${NC}

logbanner() {
    echo -e "${PURPLE}====${NC} ${1} ${PURPLE}================================"
}

loginfo() {
    echo -e "${BLUE}INFO:${NC} ${1}"
}

logerror () {
    echo -e "${RED}ERROR:${NC} ${1}"
}

logwarning () {
    echo -e "${ORANGE}WARNING:${NC} ${1}"
}