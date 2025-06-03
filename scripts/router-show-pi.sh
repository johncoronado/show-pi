#!/bin/bash
#
# raspi_router.sh (Refactored)
#
# Configures Raspberry Pi 5 as a dual-subnet router/AP:
#   - eth0: LAN_1 (192.168.10.0/24, DHCP server)
#   - wlan0: LAN_2 (192.168.4.0/24, DHCP server + AP via hostapd)
# Also supports teardown (restores backed-up config files).
#
# Usage:
#   chmod +x raspi_router.sh
#   sudo ./raspi_router.sh

set -e

BACKUP_SUFFIX=".bak-router"
DHCPCD_CONF="/etc/dhcpcd.conf"
DNSMASQ_CONF="/etc/dnsmasq.conf"
HOSTAPD_CONF="/etc/hostapd/hostapd.conf"
HOSTAPD_DEFAULT="/etc/default/hostapd"
SYSCTL_CONF="/etc/sysctl.conf"
RC_LOCAL="/etc/rc.local"
IPTABLES_RULES="/etc/iptables.rules"

backup_file() {
    [ -f "$1" ] && [ ! -f "$1$BACKUP_SUFFIX" ] && cp "$1" "$1$BACKUP_SUFFIX"
}

restore_file() {
    [ -f "$1$BACKUP_SUFFIX" ] && mv "$1$BACKUP_SUFFIX" "$1"
}

install_packages() {
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y hostapd dnsmasq iptables avahi-daemon
    systemctl stop hostapd dnsmasq
    systemctl disable hostapd dnsmasq
}

configure_dhcpcd() {
    backup_file "$DHCPCD_CONF"
    cat > "$DHCPCD_CONF" <<EOF
interface eth0
static ip_address=192.168.10.1/24
nohook wpa_supplicant

interface wlan0
static ip_address=192.168.4.1/24
nohook wpa_supplicant
EOF
}

configure_dnsmasq() {
    backup_file "$DNSMASQ_CONF"
    cat > "$DNSMASQ_CONF" <<EOF
interface=eth0
dhcp-range=192.168.10.50,192.168.10.150,255.255.255.0,24h
dhcp-option=option:router,192.168.10.1
dhcp-option=option:dns-server,192.168.10.1

interface=wlan0
dhcp-range=192.168.4.50,192.168.4.150,255.255.255.0,24h
dhcp-option=option:router,192.168.4.1
dhcp-option=option:dns-server,192.168.4.1
EOF
}

configure_hostapd() {
    backup_file "$HOSTAPD_CONF"
    mkdir -p "$(dirname $HOSTAPD_CONF)"
    cat > "$HOSTAPD_CONF" <<EOF
interface=wlan0
driver=nl80211
ssid=MyPi_RouterAP
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=StrongPass123
wpa_key_mgmt=WPA-PSK
rsn_pairwise=CCMP
EOF

    backup_file "$HOSTAPD_DEFAULT"
    echo "DAEMON_CONF=\"/etc/hostapd/hostapd.conf\"" > "$HOSTAPD_DEFAULT"
}

configure_sysctl() {
    backup_file "$SYSCTL_CONF"
    echo "net.ipv4.ip_forward=1" > "$SYSCTL_CONF"
}

configure_rc_local() {
    backup_file "$RC_LOCAL"
    cat > "$RC_LOCAL" <<EOF
#!/bin/sh -e
iptables-restore < /etc/iptables.rules
exit 0
EOF
    chmod +x "$RC_LOCAL"
}

configure_iptables() {
    backup_file "$IPTABLES_RULES"
    iptables -F
    iptables -t nat -F
    iptables -P FORWARD DROP
    iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -i wlan0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -i eth0 -o wlan0 -j ACCEPT
    iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT
    iptables-save > "$IPTABLES_RULES"
}

enable_services() {
    systemctl unmask hostapd
    systemctl enable hostapd dnsmasq avahi-daemon
    systemctl start hostapd dnsmasq avahi-daemon
}

disable_services() {
    systemctl stop hostapd dnsmasq avahi-daemon
    systemctl disable hostapd dnsmasq avahi-daemon
}

do_setup() {
    install_packages
    configure_dhcpcd && systemctl restart dhcpcd
    configure_dnsmasq
    configure_hostapd
    configure_sysctl
    sysctl -w net.ipv4.ip_forward=1
    configure_iptables
    configure_rc_local
    enable_services
    echo ">>> SETUP complete. Reboot recommended."
}

do_teardown() {
    disable_services
    restore_file "$DHCPCD_CONF"
    restore_file "$DNSMASQ_CONF"
    restore_file "$HOSTAPD_CONF"
    restore_file "$HOSTAPD_DEFAULT"
    restore_file "$SYSCTL_CONF"
    restore_file "$RC_LOCAL"

    if [ -f "$IPTABLES_RULES$BACKUP_SUFFIX" ]; then
        mv "$IPTABLES_RULES$BACKUP_SUFFIX" "$IPTABLES_RULES"
        iptables-restore < "$IPTABLES_RULES"
    else
        iptables -F
        iptables -t nat -F
        iptables -P FORWARD ACCEPT
    fi

    systemctl restart dhcpcd
    echo ">>> TEARDOWN complete. Reboot recommended."
}

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root." >&2
    exit 1
fi

echo "Raspberry Pi Dual-Subnet Router Setup"
echo "1) Setup"
echo "2) Teardown"
read -rp "Enter 1 or 2: " CHOICE

case "$CHOICE" in
    1) do_setup ;;
    2) do_teardown ;;
    *) echo "Invalid option" ; exit 1 ;;
esac
