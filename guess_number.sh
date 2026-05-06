#!/usr/bin/env bash
# Number Guessing Game

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
RESET='\033[0m'

clear

echo -e "${MAGENTA}${BOLD}"
echo "  ╔══════════════════════════════════╗"
echo "  ║      NUMBER GUESSING GAME        ║"
echo "  ╚══════════════════════════════════╝"
echo -e "${RESET}"

play_round() {
    local max=$1
    local secret=$((RANDOM % max + 1))
    local attempts=0
    local max_attempts=$2
    local guess

    echo -e "${CYAN}Guess a number between ${BOLD}1${RESET}${CYAN} and ${BOLD}${max}${RESET}"
    echo -e "${CYAN}You have ${BOLD}${max_attempts}${RESET}${CYAN} attempts.${RESET}\n"

    while [ $attempts -lt $max_attempts ]; do
        remaining=$((max_attempts - attempts))
        echo -ne "${YELLOW}[Attempt $((attempts+1))/$max_attempts] Your guess: ${RESET}"
        read -r guess

        if ! [[ "$guess" =~ ^[0-9]+$ ]]; then
            echo -e "${RED}  Please enter a valid number!${RESET}"
            continue
        fi

        attempts=$((attempts + 1))

        if [ "$guess" -eq "$secret" ]; then
            echo -e "\n${GREEN}${BOLD}  ✓ CORRECT! The number was ${secret}!${RESET}"
            echo -e "${GREEN}  Solved in ${attempts} attempt(s).${RESET}\n"
            return 0
        elif [ "$guess" -lt "$secret" ]; then
            diff=$((secret - guess))
            if [ $diff -le 5 ]; then
                echo -e "${YELLOW}  ↑ Too low — very close!${RESET}"
            elif [ $diff -le 15 ]; then
                echo -e "${CYAN}  ↑ Too low — getting warmer${RESET}"
            else
                echo -e "${RED}  ↑ Too low — way off${RESET}"
            fi
        else
            diff=$((guess - secret))
            if [ $diff -le 5 ]; then
                echo -e "${YELLOW}  ↓ Too high — very close!${RESET}"
            elif [ $diff -le 15 ]; then
                echo -e "${CYAN}  ↓ Too high — getting warmer${RESET}"
            else
                echo -e "${RED}  ↓ Too high — way off${RESET}"
            fi
        fi
    done

    echo -e "\n${RED}${BOLD}  ✗ Game Over! The number was ${secret}.${RESET}\n"
    return 1
}

total_score=0
round=1

while true; do
    echo -e "${MAGENTA}${BOLD}=== Round ${round} ===${RESET}\n"

    echo -e "${CYAN}Choose difficulty:${RESET}"
    echo -e "  ${BOLD}1${RESET}) Easy   (1-50,  10 attempts)"
    echo -e "  ${BOLD}2${RESET}) Medium (1-100,  7 attempts)"
    echo -e "  ${BOLD}3${RESET}) Hard   (1-200,  5 attempts)"
    echo -ne "\n${YELLOW}Choice [1-3]: ${RESET}"
    read -r diff_choice

    case $diff_choice in
        1) max=50;  max_att=10; label="Easy"   ;;
        2) max=100; max_att=7;  label="Medium" ;;
        3) max=200; max_att=5;  label="Hard"   ;;
        *) echo -e "${RED}Invalid choice, defaulting to Medium.${RESET}"
           max=100; max_att=7; label="Medium"  ;;
    esac

    echo -e "\n${BOLD}Difficulty: ${CYAN}${label}${RESET}\n"
    play_round $max $max_att
    result=$?

    if [ $result -eq 0 ]; then
        points=$((max_att * 10))
        total_score=$((total_score + points))
        echo -e "${GREEN}  +${points} points! Total score: ${BOLD}${total_score}${RESET}\n"
    fi

    echo -ne "${YELLOW}Play again? [y/n]: ${RESET}"
    read -r again
    if [[ "$again" != "y" && "$again" != "Y" ]]; then
        echo -e "\n${MAGENTA}${BOLD}Final Score: ${total_score} points${RESET}"
        echo -e "${CYAN}Thanks for playing!${RESET}\n"
        break
    fi

    round=$((round + 1))
    echo ""
done
