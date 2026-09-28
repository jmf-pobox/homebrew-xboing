# typed: true
# frozen_string_literal: true

# Homebrew formula for XBoing (macOS / Linux brew).
#
# Build + install only.  The brew install provides the game and the
# per-user (personal) high-score table, which the game writes under the
# user's XDG data dir at runtime — no install-time provisioning needed.
#
# There is intentionally NO shared/global leaderboard on this channel:
# the cross-user "machine" board ships only via the Debian .deb (setgid
# games + /var/games), and cross-machine standings are a future API
# leaderboard.  Homebrew sandboxes post_install and cannot provision
# shared state outside its prefix anyway.
class Xboing < Formula
  desc "Classic breakout-style arcade game (1993, modernized for SDL2)"
  homepage "https://github.com/jmf-pobox/xboing-c"
  url "https://github.com/jmf-pobox/xboing-c/archive/refs/tags/v1.0.12.tar.gz"
  sha256 "6a72bd28ee80564c3fbd06961ada3db6494cdf4ee272d6b6d4884943f0d70107"
  license "MIT"

  # Prebuilt bottles built + verified by release.yml on the v1.0.12 tag
  # (macOS arm64, Linux x86_64/aarch64). Unbottled platforms fall back to
  # the source build below automatically.
  bottle do
    root_url "https://github.com/jmf-pobox/xboing-c/releases/download/v1.0.12"
    sha256 cellar: "/home/linuxbrew/.linuxbrew/Cellar", arm64_linux: "eccba0cac96b87149d205dd789ab2ef57c5dc74dbcb9063480d03e72720a06bb"
    sha256 cellar: "/opt/homebrew/Cellar", arm64_sonoma: "6f92bfbec500af2b16f5efd64dfed124f4c3eeea3c7b40ad10fbe20a78186137"
    sha256 cellar: "/home/linuxbrew/.linuxbrew/Cellar", x86_64_linux: "967dc504cf81b2fe5d38ece3411a8b441509bc53d8c92727cd6e21939ae94c8a"
  end

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
