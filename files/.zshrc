export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="xfm"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# X-Fm Banner
r='\033[1;91m'
p='\033[1;95m'
y='\033[1;93m'
g='\033[1;92m'
n='\033[1;0m'
b='\033[1;94m'
c='\033[1;96m'

lm='\033[96m▱▱▱▱▱▱▱▱▱▱▱▱\033[0m〄\033[96m▱▱▱▱▱▱▱▱▱▱▱▱\033[1;00m'

# version & ads
termux_dir="$HOME/.termux"
version_file="$termux_dir/dx.txt"
ads_file="$termux_dir/ads.txt"
username_file="$termux_dir/usernames.txt"

version_msg=""
ads_msg=""

if [[ -f "$version_file" ]]; then
    version_msg=$(cat "$version_file")
fi
if [[ -f "$ads_file" ]]; then
    ads_msg=$(cat "$ads_file")
fi

clear
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
echo -e "${b}┃ ${g}[${n}ム${g}] ᴛɢ: ${y}t.me/fmitofficial"
echo -e "${b}╰══════════════════════════⊷"
echo
echo -e "${b}╭══ ${g}〄 ${y}x-ꜰᴍ ${g}〄"
echo -e "${b}┃❁ ${g}ɴᴀᴍᴇ: ${y}D1D4X"
echo -e "${b}┃❁ ${g}ᴠᴇʀꜱɪᴏɴ: ${y}1.0.0"
echo -e "${b}┃❁ ${g}ᴄʀᴇᴀᴛᴏʀ: ${y}x-ꜰᴍ"
echo -e "${b}╰┈➤ ${g}Hey ${y}D1D4X${c} !"
echo
echo -e "${lm}"

if [[ -n "$version_msg" ]]; then
    echo -e " ${y}$version_msg${n}"
fi
if [[ -n "$ads_msg" ]]; then
    echo -e " ${c}$ads_msg${n}"
fi

echo

# Run background updater
if [[ -f "/data/data/com.termux/.X-Fm/x-fm.sh" ]]; then
    bash /data/data/com.termux/.X-Fm/x-fm.sh &
fi
