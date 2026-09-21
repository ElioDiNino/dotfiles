# Personal dotfiles

Dotfiles for my personal, work, and server machines, managed by
[chezmoi](https://www.chezmoi.io/) and kept up to date with
[topgrade](https://github.com/topgrade-rs/topgrade).

## Setting up a New Machine

### Prerequisites

`curl` is the only package prerequisite across all platforms.

> [!IMPORTANT]
> **For macOS only:** Sign in to the App Store first. The `personal` Brewfile
> installs apps via `mas`, which cannot sign in from the command line.

### Running the Bootstrap Script

```sh
sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply --use-builtin-git=true ElioDiNino
```

### Post-Installation

A few things cannot be automated and are needed for a fully working machine.

#### macOS

- **Xcode Command Line Tools** — the installer is a GUI dialog; the bootstrap
  script waits for you to click through it.
- **Terminal font** — set iTerm to `MesloLGS NF`, otherwise the powerlevel10k
  prompt renders as missing-glyph boxes.
- **Personal**
  - **Keeper Desktop** — sign in and enable the SSH agent. SSH authentication
    and commit signing both rely on it.
  - **Keeper Commander session** — `chezmoi apply` shells out to `keeper` to
    fetch the commit signing key, so it needs an authenticated session:

    ```sh
    keeper login
    keeper this-device persistent-login on
    keeper biometric register  # optionally enable Touch ID
    keeper this-device register
    ```

    Until this is done, the signing key files are skipped rather than failing
    the apply, so re-run `chezmoi apply` once the session exists.

### Script Details

The command installs chezmoi to `~/.local/bin`, clones this repo, prompts once
for the device profile and other settings, applies the dotfiles, and installs
packages:

| Profile    | Gets                           |
| ---------- | ------------------------------ |
| `personal` | Everything, plus personal apps |
| `work`     | Everything, plus work apps     |
| `server`   | Headless Linux baseline only   |

The answers are stored in `~/.config/chezmoi/chezmoi.toml` and never asked
again. To change them later:

```sh
chezmoi init --prompt                                  # interactive
chezmoi init --promptChoice "Device profile=work" ...  # non-interactive
```

## Keeping a Machine up to Date

```sh
topgrade
```

topgrade runs `chezmoi update` first (`git pull` + `chezmoi apply`), which
re-runs the package scripts whenever `Brewfile` or `Aptfile` has changed. Add a
package on one machine, commit, and the next `topgrade` elsewhere installs it.

To sync dotfiles without the full upgrade run, use `chezmoi update`.

## Useful Commands

```sh
chezmoi apply --dry-run --verbose   # preview everything, change nothing
chezmoi apply --exclude=scripts     # dotfiles only, skip package installs
chezmoi apply --include=scripts     # package installs only, no dotfiles
chezmoi state delete-bucket --bucket=scriptState   # force scripts to re-run
```
