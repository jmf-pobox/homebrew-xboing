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
  url "https://github.com/jmf-pobox/xboing-c/archive/refs/tags/v1.0.10.tar.gz"
  sha256 "11fa535f7343d7cd5f2aded4414fe378b22092bcf47d06919a6c1d9efef5d8fc"
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
