#!/bin/bash
# Detect the actual folder this script is running from
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
clear

# X-Fm color
r='\033[1;91m'
p='\033[1;95m'
y='\033[1;93m'
g='\033[1;92m'
n='\033[1;0m'
b='\033[1;94m'
c='\033[1;96m'

# X-Fm Symbol
E='\033[1;92m[\033[1;00m×\033[1;92m]\033[1;91m'
A='\033[1;92m[\033[1;00m+\033[1;92m]\033[1;92m'
C='\033[1;92m[\033[1;00m</>\033[1;92m]\033[92m'
lm='\033[96m▱▱▱▱▱▱▱▱▱▱▱▱\033[0m〄\033[96m▱▱▱▱▱▱▱▱▱▱▱▱\033[1;00m'
dm='\033[93m▱▱▱▱▱▱▱▱▱▱▱▱\033[0m〄\033[93m▱▱▱▱▱▱▱▱▱▱▱▱\033[1;00m'

# X-Fm icon
HOST="\uf6c3"
KER="\uf83c"
HOMES="\uf015"

MODEL=$(getprop ro.product.model 2>/dev/null || echo "Unknown")
VENDOR=$(getprop ro.product.manufacturer 2>/dev/null || echo "Unknown")
THRESHOLD=100

exit_script() {
    clear
    echo
    echo -e "${c}              (\_/)"
    echo -e "              (${y}^_^${c})     ${A} ${g}Hey dear${c}"
    echo -e "             ⊂(___)づ  ⋅˚₊‧ ଳ ‧₊˚ ⋅"
    echo -e "\n ${g}Exiting ${g}X-Fm Banner"
    echo
    cd "$HOME"
    rm -rf "$SCRIPT_DIR"
    exit 0
}

# Install ncurses-utils first so tput works
if ! command -v ncurses-utils &>/dev/null; then
    pkg install ncurses-utils -y >/dev/null 2>&1
fi

trap exit_script SIGINT SIGTSTP

check_disk_usage() {
    local threshold=${1:-$THRESHOLD}
    local total_size used_size disk_usage
    total_size=$(df -h "$HOME" | awk 'NR==2 {print $2}')
    used_size=$(df -h "$HOME" | awk 'NR==2 {print $3}')
    disk_usage=$(df "$HOME" | awk 'NR==2 {print $5}' | sed 's/%//g')
    if [ "$disk_usage" -ge "$threshold" ]; then
        echo -e "${g}[\uf0a0] ${r}WARN: ${y}Disk Full ${g}${disk_usage}% ${c}| U${g}${used_size} ${c}of T${g}${total_size}"
    else
        echo -e "${y}Disk: ${g}${disk_usage}% ${c}| ${g}${used_size}"
    fi
}
data=$(check_disk_usage)

# ── Intro screen (no per-character sleep) ──
start() {
    clear
    echo
    echo
    echo -e "\033[1;92m  ╔══════════════════════════════╗"
    echo -e "  ║   \033[1;96m[ X-Fm STARTED ]          \033[1;92m║"
    echo -e "  ║   \033[1;93mHELLO DEAR USER           \033[1;92m║"
    echo -e "  ║   \033[1;95mX-Fm WILL PROTECT YOU     \033[1;92m║"
    echo -e "  ║   \033[1;96mENJOY OUR X-Fm BANNER     \033[1;92m║"
    echo -e "  ╚══════════════════════════════╝\033[0m"
    echo
    sleep 1.5
    clear
}
start

mkdir -p .X-Fm

# ── Helpers ──
ensure_curl() {
    if ! command -v curl &>/dev/null; then
        pkg install curl -y &>/dev/null 2>&1
    fi
}

help() {
    clear
    echo
    echo -e " ${p}■ \e[4m${g}Navigation\e[0m ${p}▪︎${n}"
    echo
    echo -e " ${y}Use Termux Extra key Buttons${n}"
    echo
    echo -e "  UP    ↑   move up"
    echo -e "  DOWN  ↓   move down"
    echo -e "  ENTER     select option"
    echo
    echo -e " ${b}Press Enter to continue${n}"
    read -r
}
help

# ── Spinner for installs ──
spin() {
    echo
    local delay=0.30
    local spinner=('█■■■■' '■█■■■' '■■█■■' '■■■█■' '■■■■█')

    show_spinner() {
        local pid=$!
        while ps -p $pid > /dev/null 2>&1; do
            for i in "${spinner[@]}"; do
                tput civis 2>/dev/null
                echo -ne "\033[1;96m\r [+] Installing $1 ... \e[33m[\033[1;92m$i\033[1;93m]\033[0m   "
                sleep $delay
            done
        done
        tput cnorm 2>/dev/null
        echo -e "\r\e[1;92m [✓] Done: $1\e[0m          "
        echo
    }

    apt update >/dev/null 2>&1
    apt upgrade -y >/dev/null 2>&1

    local packages=("git" "python" "ncurses-utils" "jq" "figlet" "termux-api" "lsd" "zsh" "ruby" "exa")
    for package in "${packages[@]}"; do
        if ! dpkg -l 2>/dev/null | grep -q "^ii  $package "; then
            pkg install "$package" -y >/dev/null 2>&1 &
            show_spinner "$package"
        fi
    done

    if ! command -v lolcat >/dev/null 2>&1; then
        pip install lolcat >/dev/null 2>&1 &
        show_spinner "lolcat"
    fi

    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh >/dev/null 2>&1 &
        show_spinner "oh-my-zsh"
    fi

    rm -rf /data/data/com.termux/files/usr/etc/motd >/dev/null 2>&1

    if [ "$SHELL" != "/data/data/com.termux/files/usr/bin/zsh" ]; then
        chsh -s zsh >/dev/null 2>&1 &
        show_spinner "zsh-shell"
    fi

    if [ ! -f "$HOME/.zshrc" ]; then
        cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc &
        show_spinner "zshrc"
    fi

    if [ ! -d "$HOME/.oh-my-zsh/plugins/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions \
            "$HOME/.oh-my-zsh/plugins/zsh-autosuggestions" >/dev/null 2>&1 &
        show_spinner "zsh-autosuggestions"
    fi

    if [ ! -d "$HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
            "$HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting" >/dev/null 2>&1 &
        show_spinner "zsh-syntax-highlighting"
    fi

    if ! gem list lolcat 2>/dev/null | grep -q lolcat; then
        echo "y" | gem install lolcat >/dev/null 2>&1 &
        show_spinner "lolcat (gem)"
    fi
}

# ── Copy files ──
setup() {
    local ds="$HOME/.termux"
    mkdir -p "$ds"

    [ ! -f "$ds/font.ttf" ]           && cp "$SCRIPT_DIR/files/font.ttf" "$ds/"
    [ ! -f "$ds/colors.properties" ]  && cp "$SCRIPT_DIR/files/colors.properties" "$ds/"

    cp "$SCRIPT_DIR/files/ASCII-Shadow.flf" "$PREFIX/share/figlet/" 2>/dev/null
    cp "$SCRIPT_DIR/files/remove" "/data/data/com.termux/files/usr/bin/remove"
    chmod +x "/data/data/com.termux/files/usr/bin/remove"
    termux-reload-settings 2>/dev/null
}

# ── Internet check ──
netcheck() {
    clear
    echo
    echo -e "  ${g}╔══════════════════════════════════════╗"
    echo -e "  ${g}║  ${C} ${y}Checking internet connection...${g}  ║"
    echo -e "  ${g}╚══════════════════════════════════════╝${n}"
    while true; do
        if curl --silent --head --fail https://github.com > /dev/null 2>&1; then
            break
        fi
        echo -e "  ${E} ${r}No internet — retrying...${n}"
        sleep 2.5
    done
    clear
}

# ── Banner name setup ──
donotchange() {
    clear
    echo
    echo -e "${c}              (\_/)"
    echo -e "              (${y}^_^${c})     ${A} ${g}Hey dear${c}"
    echo -e "             ⊂(___)づ  ⋅˚₊‧ ଳ ‧₊˚ ⋅"
    echo
    echo -e " ${A} ${c}Please Enter Your ${g}Banner Name ${y}(1-8 chars)${c}"
    echo

    while true; do
        read -rp "[+]──[Enter Your Name]────► " name
        echo
        if [[ ${#name} -ge 1 && ${#name} -le 8 ]]; then
            break
        fi
        echo -e " ${E} ${r}Name must be 1-8 characters. Try again.${n}"
        echo
    done

    local D1="$HOME/.termux"
    mkdir -p "$D1"

    local TEMP_FILE="$HOME/temp_xfm.zshrc"
    sed "s/D1D4X/$name/g" "$SCRIPT_DIR/files/.zshrc"       > "$TEMP_FILE"
    sed "s/D1D4X/$name/g" "$SCRIPT_DIR/files/.xfm.zsh-theme" \
        > "$HOME/.oh-my-zsh/themes/xfm.zsh-theme" 2>/dev/null

    echo "$name" > "$D1/usernames.txt"
    echo ""      > "$D1/dx.txt"
    echo ""      > "$D1/ads.txt"

    if mv "$TEMP_FILE" "$HOME/.zshrc"; then
        clear
        echo
        echo -e "          ${g}Hey ${y}$name  ${g}✓ Banner created!"
        echo -e "${c}              (\_/)"
        echo -e "              (${y}^ω^${c})     ${g}I'm X-Fm${c}"
        echo -e "             ⊂(___)づ  ⋅˚₊‧ ଳ ‧₊˚ ⋅"
        echo
        sleep 2
    else
        echo -e " ${E} ${r}Error creating banner.${n}"
        rm -f "$TEMP_FILE"
        sleep 1
    fi
    clear
}

# ── Banner display ──
banner() {
    echo
    echo
    echo -e "   ${g}██╗  ██╗      ${c}███████╗███╗   ███╗"
    echo -e "   ${g}╚██╗██╔╝      ${c}██╔════╝████╗ ████║"
    echo -e "   ${g} ╚███╔╝ █████╗${c}█████╗  ██╔████╔██║"
    echo -e "   ${g} ██╔██╗ ╚════╝${c}██╔══╝  ██║╚██╔╝██║"
    echo -e "   ${g}██╔╝ ██╗      ${c}██║     ██║ ╚═╝ ██║"
    echo -e "   ${g}╚═╝  ╚═╝      ${c}╚═╝     ╚═╝     ╚═╝${n}"
    echo -e "${y}               +-+-+-+-+-+"
    echo -e "${c}               |X|-|F|m| |"
    echo -e "${y}               +-+-+-+-+-+${n}"
    echo
    echo -e "${b}╭══════════════════════════⊷"
    echo -e "${b}┃ ${g}[ム] ᴛɢ: ${y}t.me/fmitofficial"
    echo -e "${b}╰══════════════════════════⊷"
    echo
    echo -e "${b}╭══ ${g}〄 ${y}x-ꜰᴍ ${g}〄"
    echo -e "${b}┃❁ ${g}ᴄʀᴇᴀᴛᴏʀ: ${y}x-ꜰᴍ"
    echo -e "${b}┃❁ ${g}ᴠᴇʀꜱɪᴏɴ: ${y}1.0.0"
    echo -e "${b}┃❁ ${g}ᴅᴇᴠɪᴄᴇ: ${y}${VENDOR} ${MODEL}"
    echo -e "${b}╰┈➤ ${g}Hey ${y}Dear"
    echo
}

# ── Main install flow ──
setupx() {
    if [ ! -d "/data/data/com.termux/files/usr/" ]; then
        echo -e " ${E} ${r}This script only works on Termux (Android).${n}"
        sleep 3
        exit 1
    fi

    ensure_curl
    netcheck
    banner
    echo -e " ${C} ${y}Termux detected — starting setup...${n}"
    echo -e " ${lm}"
    echo -e " ${A} ${g}Installing packages, please wait...${n}"
    echo -e " ${dm}"
    spin
    clear
    banner
    echo -e " ${A} ${p}Packages installed successfully!${n}"
    echo -e " ${dm}"
    sleep 1
    clear
    banner
    echo -e " ${C} ${c}Setting up files...${n}"
    setup
    donotchange
    clear
    banner
    echo -e " ${C} ${c}All done! Type ${g}exit${c} then reopen Termux.${n}"
    echo
    sleep 3
    cd "$HOME"
    rm -rf "$SCRIPT_DIR"
    exit 0
}

# ── Menu ──
banner2() {
    clear
    banner
    echo -e "${c}╭════════════════════════════════════════════════⊷"
    echo -e "${c}┃ ${p}❏ ${g}Use ↑ ↓ to navigate, Enter to select${n}"
    echo -e "${c}╰════════════════════════════════════════════════⊷"
}

options=("Free Usage" "Premium")
selected=0

display_menu() {
    banner2
    echo
    echo -e " ${g}■ \e[4m${p}Select An Option\e[0m ${g}▪︎${n}"
    echo
    for i in "${!options[@]}"; do
        if [ $i -eq $selected ]; then
            echo -e " ${g}〄> ${c}${options[$i]} ${g}<〄${n}"
        else
            echo -e "     ${options[$i]}"
        fi
    done
}

while true; do
    display_menu
    read -rsn1 input
    if [[ "$input" == $'\e' ]]; then
        read -rsn2 -t 0.1 input
        case "$input" in
            '[A')
                ((selected--))
                [ $selected -lt 0 ] && selected=$(( ${#options[@]} - 1 ))
                ;;
            '[B')
                ((selected++))
                [ $selected -ge ${#options[@]} ] && selected=0
                ;;
        esac
    elif [[ "$input" == "" ]]; then
        case ${options[$selected]} in
            "Free Usage")
                echo -e "\n ${A} ${c}Starting free setup...${n}"
                sleep 1
                setupx
                ;;
            "Premium")
                echo -e "\n ${g}Opening Telegram...${n}"
                sleep 1
                xdg-open "https://t.me/fmitofficial" 2>/dev/null || \
                    termux-open-url "https://t.me/fmitofficial" 2>/dev/null
                cd "$HOME"
                rm -rf "$SCRIPT_DIR"
                exit 0
                ;;
        esac
    fi
done