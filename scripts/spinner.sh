# spinner.sh
spinner() {
    local pid=$1
    local message=$2
    local logfile=${3:-}

    local delay=0.1
    local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    tput civis
    local i=0

    while kill -0 "$pid" 2>/dev/null; do
        local frame=${frames[$i]}
        printf "\r\e[35m%s\e[0m %s" "$frame" "$message"
        i=$(((i + 1) % ${#frames[@]}))
        sleep $delay
    done

    wait $pid
    local EXIT=$?
    tput cnorm

    if [ $EXIT -eq 0 ]; then
        printf "\r\e[32m✔\e[0m %s\n" "$message"
    else
        printf "\r\e[31m✖\e[0m %s\n" "$message"
        if [ -n "$logfile" ]; then
            echo "    See $logfile for details. Last 20 lines:"
            tail -20 "$logfile"
        fi
    fi
}
