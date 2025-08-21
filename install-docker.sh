#!/usr/bin/env bash
set -euo pipefail

echo "[INFO] Устанавливаю Docker и Docker Compose..."

# === Установка Docker Engine ===
echo "[INFO] Обновляю список пакетов..."
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg lsb-release

echo "[INFO] Добавляю официальный GPG ключ Docker..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "[INFO] Добавляю репозиторий Docker..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "[INFO] Устанавливаю Docker Engine..."
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# === Установка Docker Compose (последний релиз с GitHub) ===
echo "[INFO] Скачиваю последнюю версию Docker Compose..."
COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name":' | sed -E 's/.*"v?([^"]+)".*/\1/')
sudo curl -L "https://github.com/docker/compose/releases/download/v${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

# === Добавляем пользователя в группу docker ===
if ! groups $USER | grep -q docker; then
  echo "[INFO] Добавляю пользователя $USER в группу docker..."
  sudo usermod -aG docker $USER
  echo "[WARN] Нужно выйти и заново войти в систему, чтобы изменения вступили в силу."
fi

# === Проверка установки ===
echo "[INFO] Проверяю версии..."
docker --version
docker-compose --version

echo "[INFO] Установка завершена успешно!"
