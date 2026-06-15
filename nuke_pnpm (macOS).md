# Nuke & Reinstall pnpm (macOS)

When pnpm gets into a broken state (corrupted store, self-update gone wrong, missing binary), wipe it completely and reinstall fresh.

## 1. Remove everything pnpm

```bash
rm -rf ~/Library/pnpm          # store, global bin, the binary itself
rm -rf ~/Library/Caches/pnpm   # cache
rm -rf ~/.pnpm-store           # legacy store (if present)
rm -rf ~/.pnpm-state           # legacy state (if present)
```

> The `PNPM_HOME` block in `~/.zshrc` can stay — the installer reuses it and won't duplicate it.

## 2. Reinstall (standalone)

```bash
curl -fsSL https://get.pnpm.io/install.sh | sh -
```

## 3. Reload shell & verify

```bash
exec zsh
pnpm --version
```

## 4. Reinstall project deps

```bash
rm -rf node_modules
pnpm install
```

---

**Note:** Use `pnpm self-update` to update only if pnpm was installed via this standalone script. If pnpm is managed by Corepack instead, update through the `packageManager` field in `package.json` or `corepack use pnpm@latest` — don't mix the two.
