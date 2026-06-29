# Submitting xboing to homebrew-core

Runbook for promoting the formula from this tap into `Homebrew/homebrew-core`
so `brew install xboing` works with no tap. Everything here is validated;
only the final fork + PR is left (deliberately not yet done).

## Local validation — all green (macOS arm64, 2026-06-29)

Run against this tap's formula:

```bash
brew audit --strict --online --new jmf-pobox/xboing/xboing   # exit 0
brew style jmf-pobox/xboing/xboing                           # exit 0
brew install --build-from-source jmf-pobox/xboing/xboing     # builds from the v0.9 tarball
brew test jmf-pobox/xboing/xboing                            # asserts `xboing -version` -> 0.9
brew livecheck jmf-pobox/xboing/xboing                       # guessed: 0.9 ==> 0.9 (Git tag strategy)
brew audit --strict --online jmf-pobox/xboing/xboing         # exit 0 (installed)
```

`brew test-bot` wraps audit + build-from-source + test + bottling; the first
three are covered above, and bottles are built by core CI after merge (a new
formula does not ship its own bottles).

## Still to verify before submitting

- **Linux build.** Core's `test-bot` builds on Linux; confirm `brew install
  --build-from-source` succeeds under Homebrew on Linux first to avoid a
  failed submission. (Apple-silicon macOS verified here; Intel macOS is
  covered by core CI.)

## The core formula (`Formula/x/xboing.rb`)

Same as this tap's `Formula/xboing.rb` but **without** the `# typed:` /
`# frozen_string_literal:` sigils (core does not use them):

```ruby
class Xboing < Formula
  desc "Classic breakout-style arcade game (1993, modernized for SDL2)"
  homepage "https://github.com/jmf-pobox/xboing-c"
  url "https://github.com/jmf-pobox/xboing-c/archive/refs/tags/v0.9.tar.gz"
  sha256 "01495374fa98f9b029280d628d6129f2308daf51d7b09f059bb473055916d53e"
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
#    PR title:  xboing 0.9 (new formula)
```

## PR notability justification

> **XBoing** is a breakout/blockout arcade game written by Justin C. Kibell
> for the X Window System between 1993 and 1996 (v2.4 released 22 Nov 1996),
> distributed via `ftp.x.org/contrib/games`. It was a widely recognized X11
> game of its era — packaged in Debian (`xboing`) and other distributions
> for years and a fixture of 1990s/2000s Linux game collections. The
> original pure-Xlib codebase has been unmaintained for 20+ years.
>
> This formula packages the maintained SDL2 modernization — a faithful port
> preserving all 80 levels, the original ball physics, 30 block types,
> power-ups, multiball, and the built-in editor — installable on modern
> macOS and Linux without X11. MIT-licensed, stable v0.9 release.
>
> On notability: the game is a 30-year-old classic with a long packaging
> history; this is its canonical maintained continuation. On the repo's
> youth: the port is new, but it is the actively maintained successor to
> notable software, not a brand-new project.
