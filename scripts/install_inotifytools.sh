if ! dpkg -s inotify-tools >/dev/null 2>&1; then
    echo "📦 inotify-tools not found. Installing..."
    sudo apt update && sudo apt install -y inotify-tools
else
    echo "✅ inotify-tools already installed."
fi
