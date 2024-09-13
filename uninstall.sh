echo -e "OSU Uninstaller\n"

read -p "Are you sure you would like to uninstall? [y/N] " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf ~/.local/share/osu-asahi
    rm -f ~/.local/bin/osu
    rm -f ~/.local/share/applications/osu-asahi.desktop
    rm -rf /tmp/osu-asahi
    echo "Uninstall complete"
else
    echo "Uninstall cancelled"
    exit 1
fi
