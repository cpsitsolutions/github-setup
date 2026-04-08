# GitHub Setup

One-line script to configure Git and GitHub SSH on macOS.

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/cpsitsolutions/github-setup/main/setup.sh | bash
```

## What it does

- ✅ Checks if Git is installed (offers to install via Homebrew)
- ✅ Configures `user.name` and `user.email`
- ✅ Generates ED25519 SSH key
- ✅ Adds key to ssh-agent
- ✅ Configures commit signing (verified badge)
- ✅ Copies public key to clipboard

## After running

1. Open [github.com/settings/keys](https://github.com/settings/keys)
2. Click **New SSH key** → paste key → **Add**
3. Click **New SSH key** again → Type: **Signing Key** → paste same key
4. Test: `ssh -T git@github.com`

## Requirements

- macOS
- Terminal access

## Manual install

```bash
git clone git@github.com:cpsitsolutions/github-setup.git
cd github-setup
chmod +x setup.sh
./setup.sh
```

## License

MIT