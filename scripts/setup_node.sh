
echo "[+] Installing Node.js and npm via nvm..."

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.7/install.sh | bash

\. "$HOME/.nvm/nvm.sh"

nvm install 24

node -v
nvm current
npm -v

echo "[✔] Node.js and npm installation complete."