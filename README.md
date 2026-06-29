# homebrew-xboing

Homebrew tap for [XBoing](https://github.com/jmf-pobox/xboing-c) — the
classic 1993 X11 breakout game, modernized for SDL2.

## Install

```bash
brew tap jmf-pobox/xboing
brew install xboing
```

Then run:

```bash
xboing
```

To build the latest unreleased code from `master` instead of the tagged
release:

```bash
brew install --HEAD jmf-pobox/xboing/xboing
```

## Notes

- High scores are per-user, stored under your XDG data dir
  (`~/.local/share/xboing/`).
- The shared cross-user "machine" leaderboard ships only via the Debian
  `.deb` package (it needs a privileged setgid install Homebrew cannot
  provide); a cross-machine global leaderboard is planned via a network
  service.

## Updating the formula on a new release

1. Tag the release in `xboing-c` (e.g. `git tag -a vX.Y && git push origin vX.Y`).
2. `curl -sL https://github.com/jmf-pobox/xboing-c/archive/refs/tags/vX.Y.tar.gz | shasum -a 256`
3. Update `url` and `sha256` in `Formula/xboing.rb` and push.
