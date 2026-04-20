ZSH_THEME="xfm"
export ZSH=$HOME/.oh-my-zsh
plugins=(git)

source $HOME/.oh*/oh-my-zsh.sh
source /data/data/com.termux/files/home/.oh-my-zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /data/data/com.termux/files/home/.oh-my-zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
alias ls='lsd'
alias rd='termux-reload-settings'

clear

r='\033[91m'
p='\033[1;95m'
y='\033[93m'
g='\033[92m'
n='\033[0m'
b='\033[94m'
c='\033[96m'

X='\033[1;92m[\033[1;00m⎯꯭̽𓆩\033[1;92m]\033[1;96m'
D='\033[1;92m[\033[1;00m〄\033[1;92m]\033[1;93m'
E='\033[1;92m[\033[1;00m×\033[1;92m]\033[1;91m'
A='\033[1;92m[\033[1;00m+\033[1;92m]\033[1;92m'
C='\033[1;92m[\033[1;00m</>\033[1;32m]\033[1;92m'
lm='\033[96m▱▱▱▱▱▱▱▱▱▱▱▱\033[0m〄\033[96m▱▱▱▱▱▱▱▱▱▱▱▱\033[1;00m'
dm='\033[93m▱▱▱▱▱▱▱▱▱▱▱▱\033[0m〄\033[93m▱▱▱▱▱▱▱▱▱▱▱▱\033[1;00m'
aHELL="\uf489"
TERMINAL="\ue7a2"
PKGS="\uf8d6"
CAL="\uf073"

bol='\033[1m'
bold="${bol}\e[4m"
THRESHOLD=100

check_disk_usage() {
    local threshold=${1:-$THRESHOLD}
    local total_size
    local used_size
    local disk_usage

    total_size=$(df -h "$HOME" | awk 'NR==2 {print $2}')
    used_size=$(df -h "$HOME" | awk 'NR==2 {print $3}')
    disk_usage=$(df "$HOME" | awk 'NR==2 {print $5}' | sed 's/%//g')

    if [ "$disk_usage" -ge "$threshold" ]; then
        echo -e " ${g}[${n}\uf0a0${g}] ${r}WARN: ${c}Disk Full ${g}${disk_usage}% ${c}| ${c}U${g}${used_size} ${c}of ${c}T${g}${total_size}"
    else
        echo -e " ${g}[${n}\uf0e7${g}] ${c}Disk usage: ${g}${disk_usage}% ${c}| ${c}U${g}${used_size} ${c}of ${c}T${g}${total_size}"
    fi
}

data=$(check_disk_usage)

# ── Auto-Update ──────────────────────────────────────────────
GITHUB_RAW="https://raw.githubusercontent.com/X-Fm/x-fmBanner/main"
LOCAL_VERSION_FILE="$HOME/.termux/xfm_version.txt"

auto_update() {
    # Internet check — skip silently if offline
    curl --silent --head --fail https://github.com > /dev/null 2>&1 || return

    _xfm_remote=$(curl -fsSL "$GITHUB_RAW/version.txt" 2>/dev/null | tr -d '[:space:]')
    [ -z "$_xfm_remote" ] && return

    if [ -f "$LOCAL_VERSION_FILE" ]; then
        _xfm_local=$(cat "$LOCAL_VERSION_FILE" | tr -d '[:space:]')
    else
        _xfm_local=""
    fi

    if [ "$_xfm_remote" != "$_xfm_local" ]; then
        clear
        echo
        echo -e " ${A} ${c}New update found! ${g}v${_xfm_remote}${c} — updating...${n}"
        echo -e " ${lm}"
        cd "$HOME"
        rm -rf x-fmBanner
        git clone https://github.com/X-Fm/x-fmBanner.git > /dev/null 2>&1
        if [ -d "$HOME/x-fmBanner" ]; then
            echo "$_xfm_remote" > "$LOCAL_VERSION_FILE"
            cd x-fmBanner
            bash install.sh
        else
            echo -e " ${E} ${r}Update failed. Check your internet.${n}"
            sleep 2
        fi
    fi
}

auto_update
# ─────────────────────────────────────────────────────────────

load() {
    clear
    echo -e "${TERMINAL}${r}●${n}"
    sleep 0.2
    clear
    echo -e "${TERMINAL}${r}●${y}●${n}"
    sleep 0.2
    clear
    echo -e "${TERMINAL}${r}●${y}●${b}●${n}"
    sleep 0.2
}

widths=$(stty size | awk '{print $2}')
width=$(tput cols)
var=$((width - 1))
var2=$(seq -s═ ${var} | tr -d '[:digit:]')
var3=$(seq -s\  ${var} | tr -d '[:digit:]')
var4=$((width - 20))

PUT() { echo -en "\033[${1};${2}H"; }
HIDECURSOR() { echo -en "\033[?25l"; }
NORM() { echo -en "\033[?12l\033[?25h"; }

HIDECURSOR
load
clear

width=$(tput cols)
prefix="${TERMINAL}${r}●${y}●${b}●${n}"
clean_prefix=$(echo -e "$prefix" | sed 's/\x1b\[[0-9;]*m//g')
prefix_len=${#clean_prefix}
clean_data=$(echo -e "${data}" | sed 's/\x1b\[[0-9;]*m//g')
data_len=${#clean_data}
data_start=$(((width - data_len) / 2))
padding=$((data_start - prefix_len))
if [ $padding -lt 0 ]; then padding=0; fi
spaces=$(printf '%*s' $padding "")
echo -e "${prefix}${spaces}${data}${c}"

echo "╔${var2}╗"
for ((i=1; i<=8; i++)); do
    echo "║${var3}║"
done
echo "╚${var2}╝"
PUT 4 0
figlet -c -f ASCII-Shadow -w $width D1D4X | lolcat
PUT 3 0
echo -e "\033[36;1m"
for ((i=1; i<=7; i++)); do
    echo "║"
done
PUT 10 ${var4}
echo -e "\e[32m[\e[0m\uf489\e[32m] \e[36mX-Fm \e[36m1.0.0\e[0m"
PUT 12 0
# Date/Time — centered
_dt_line() {
    local day tm dt full
    day=$(date +"%a")
    tm=$(date +"%I:%M:%S %p")
    dt=$(date +"%d-%m-%Y")
    full="${day}  ${tm}  ${dt}"
    local len=${#full}
    local w
    w=$(tput cols 2>/dev/null || echo 40)
    local pad=$(( (w - len) / 2 ))
    [ $pad -lt 0 ] && pad=0
    printf "%${pad}s" ""
    echo -e "${g}${day}${n}  ${c}${tm}${n}  ${y}${dt}${n}"
}
_dt_line
NORM
