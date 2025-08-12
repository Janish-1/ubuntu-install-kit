# ---- Xarchiver ----
if ! command -v xarchiver &> /dev/null; then
  echo "📦 Installing Xarchiver..."
  sudo apt update
  sudo apt install -y xarchiver
else
  echo "✅ Xarchiver already installed."
fi