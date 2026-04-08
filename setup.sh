#!/bin/bash

set -e

echo "🔧 Git + GitHub Setup"
echo "====================="
echo ""

# Проверяем git
if ! command -v git &> /dev/null; then
    echo "❌ Git не установлен"
    echo ""
    read -p "Установить через Homebrew? (y/n): " install_git
    if [ "$install_git" = "y" ]; then
        if command -v brew &> /dev/null; then
            brew install git
        else
            echo "❌ Homebrew не установлен. Установи git вручную:"
            echo "   xcode-select --install"
            echo "   или brew install git"
            exit 1
        fi
    else
        exit 1
    fi
fi

echo "✓ Git $(git --version | cut -d' ' -f3)"
echo ""

# Для работы через curl | bash
if [ -t 0 ]; then
    # Интерактивный режим
    read -p "Введи имя (user.name): " username
    read -p "Введи email: " email
else
    # Через pipe — читаем из /dev/tty
    exec < /dev/tty
    read -p "Введи имя (user.name): " username
    read -p "Введи email: " email
fi

# Проверка
if [ -z "$username" ] || [ -z "$email" ]; then
    echo "❌ Имя и email обязательны"
    exit 1
fi

# Настраиваем git
echo ""
echo "⚙️  Настраиваю git..."
git config --global user.name "$username"
git config --global user.email "$email"

# Генерируем ключ
key_file="$HOME/.ssh/id_ed25519"

if [ -f "$key_file" ]; then
    if [ -t 0 ] || [ -t 2 ]; then
        exec < /dev/tty
        read -p "⚠️  SSH ключ уже существует. Перезаписать? (y/n): " overwrite
        if [ "$overwrite" != "y" ]; then
            echo "Использую существующий ключ"
        else
            ssh-keygen -t ed25519 -C "$email" -f "$key_file" -N ""
        fi
    else
        echo "Использую существующий ключ"
    fi
else
    echo ""
    echo "🔑 Генерирую SSH ключ..."
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    ssh-keygen -t ed25519 -C "$email" -f "$key_file" -N ""
fi

# Права на ключ
chmod 600 "$key_file"
chmod 644 "$key_file.pub"

# Добавляем в ssh-agent
eval "$(ssh-agent -s)" > /dev/null 2>&1
ssh-add "$key_file" 2>/dev/null

# Настраиваем подпись коммитов
git config --global gpg.format ssh
git config --global user.signingkey "$key_file.pub"
git config --global commit.gpgsign true

# Выводим результат
echo ""
echo "✅ Готово!"
echo ""
echo "📋 Твой публичный ключ:"
echo "==========================================="
cat "$key_file.pub"
echo "==========================================="
echo ""

# Копируем в буфер если доступен pbcopy
if command -v pbcopy &> /dev/null; then
    pbcopy < "$key_file.pub"
    echo "📎 Ключ скопирован в буфер обмена"
    echo ""
fi

echo "🔗 Теперь:"
echo "   1. Открой https://github.com/settings/keys"
echo "   2. Нажми 'New SSH key' → вставь ключ"
echo "   3. Ещё раз 'New SSH key' → Type: 'Signing Key'"
echo ""
echo "📝 Проверка: ssh -T git@github.com"
