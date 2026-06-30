# Submitting xboing to homebrew-core

Runbook for promoting the formula from this tap into `Homebrew/homebrew-core`
so `brew install xboing` works with no tap. Everything here is validated;
only the final fork + PR is left (deliberately not yet done).

## Local validation — all green (macOS arm64, 2026-06-29)

Run against this tap's formula:

```bash
brew audit --strict --online --new jmf-pobox/xboing/xboing   # exit 0
brew style jmf-pobox/xboing/xboing                           # exit 0
brew install --build-from-source jmf-pobox/xboing/xboing     # builds from the v1.0 tarball
brew test jmf-pobox/xboing/xboing                            # asserts `xboing -version` -> 1.0
brew livecheck jmf-pobox/xboing/xboing                       # guessed: 1.0 ==> 1.0 (Git tag strategy)
brew audit --strict --online jmf-pobox/xboing/xboing         # exit 0 (installed)
```

`brew test-bot` wraps audit + build-from-source + test + bottling; the first
three are covered above, and bottles are built by core CI after merge (a new
formula does not ship its own bottles).

## Cross-platform verification — done

- **macOS (Apple silicon)** — `audit --new`, `style`, `install
  --build-from-source`, `test`, `livecheck` all green (2026-06-29). Intel
  macOS is covered by core CI.
- **Linux (Ubuntu 24.04.4, Linuxbrew 6.0.5)** — verified 2026-06-30 against
  v0.9 + `--HEAD`: `brew install` clean; `brew audit --strict --online`
  exit 0 with **zero findings**; `brew test` exit 0; `--HEAD` builds clean.
  Runtime journey passed (`xboing -version` correct, `xboing -scores` →
  personal table with no `/var/games` leak, `man xboing` renders, headless
  dummy-driver launch has no init errors). v1.0 is the same formula (version
  + sha bump only); `--HEAD` already covered the post-#163 tree that v1.0
  tags. This is the Linux leg core's `test-bot` exercises.

## The core formula (`Formula/x/xboing.rb`)

Same as this tap's `Formula/xboing.rb` but **without** the `# typed:` /
`# frozen_string_literal:` sigils (core does not use them):

```ruby
class Xboing < Formula
  desc "Classic breakout-style arcade game (1993, modernized for SDL2)"
  homepage "https://github.com/jmf-pobox/xboing-c"
  url "https://github.com/jmf-pobox/xboing-c/archive/refs/tags/v1.0.tar.gz"
  sha256 "b04dad25ddaa1c2ee7088abfb490765fb34bfaf0fed3ff30f23b61da88954b33"
  license "MIT"
  head "https://github.com/jmf-pobox/xboing-c.git", branch: "master"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "sdl2"
  depends_on "sdl2_image"
  depends_on "sdl2_mixer"
  depends_on "sdl2_ttf"

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    assert_match "xboing #{version}", shell_output("#{bin}/xboing -version")
  end
end
```

## Submission steps (when ready)

```bash
# 1. Fork + clone homebrew-core (one-time)
brew tap --force homebrew/core            # or: gh repo fork Homebrew/homebrew-core
HOMEBREW_NO_INSTALL_FROM_API=1 brew update

# 2. Drop the core formula in
cp xboing.rb "$(brew --repository homebrew/core)/Formula/x/xboing.rb"  # sigil-free version above

# 3. Validate in the core tap
brew audit --strict --online --new xboing
brew install --build-from-source xboing
brew test xboing

# 4. Branch, commit, push to your fork, open the PR
#    PR title:  xboing 1.0 (new formula)
```

## PR notability justification

Paste into the homebrew-core PR description (under the auto-generated checklist):

> **XBoing** is a breakout/blockout arcade game written by Justin C. Kibell
> for the X Window System between 1993 and 1997 — version 2.4 shipped on
> 22 November 1996 and was distributed worldwide via
> `ftp.x.org/contrib/games`. It became a staple of 1990s/2000s Unix game
> collections and was packaged across most major distributions:
>
> - **Debian** (`xboing`, maintained by the Debian Games Group through
>   `2.4-31`) and, by inheritance, **Ubuntu**.
> - **Red Hat Linux** (1996–1997), shipped in the X11R6 `contrib`
>   collection on the distribution CD-ROMs.
> - Still carried today by **Gentoo**, **FreeBSD ports**
>   (`games/xboing`, since ~2002, MIT/X11 license), **NetBSD/pkgsrc**,
>   **Raspbian**, **ALT Linux**, and **RPM Sphere** (per Repology).
>
> To be precise: it was widely *packaged* across Unix for 25+ years, not
> part of any distribution's default install. The original pure-Xlib
> codebase has been unmaintained since 1997.
>
> This formula packages the **maintained SDL2 modernization** — a faithful
> port preserving all 80 levels, the original ball physics, 30 block types,
> power-ups, multiball, and the built-in level editor — that installs on
> modern macOS and Linux with no X11 dependency. MIT-licensed.
>
> **On the repository's youth:** the *game* is a 30-year-old classic with a
> long cross-distribution packaging history; this repository is its canonical
> maintained continuation (now at its first **stable 1.0** release), not a
> brand-new project.

Sources for the packaging history (keep handy for maintainer questions, not
in the PR body): Debian tracker (`tracker.debian.org/pkg/xboing`, last
`2.4-31`), Ubuntu (`launchpad.net/ubuntu/+source/xboing`), Red Hat 5.2 docs
(X11R6 contrib), Repology (`repology.org/project/xboing/versions`, 12 repos),
FreshPorts (`freshports.org/games/xboing`).
