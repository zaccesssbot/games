# Homebrew formula template for Zacess Games. Replace VERSION with the release version (without
# the v) and each SHA256_ placeholder with the sum from the matching .sha256 file on the release,
# then copy it to Formula/zacess-games.rb in the zacesshq/homebrew-tap repository.
class ZacessGames < Formula
  desc "Fourteen original games for the terminal in the Zacess high contrast themes"
  homepage "https://zacess.com"
  version "VERSION"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/zacesshq/games/releases/download/vVERSION/zacess-games-vVERSION-aarch64-apple-darwin.tar.gz"
      sha256 "SHA256_MACOS_ARM"
    end
    on_intel do
      url "https://github.com/zacesshq/games/releases/download/vVERSION/zacess-games-vVERSION-x86_64-apple-darwin.tar.gz"
      sha256 "SHA256_MACOS_INTEL"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/zacesshq/games/releases/download/vVERSION/zacess-games-vVERSION-aarch64-unknown-linux-musl.tar.gz"
      sha256 "SHA256_LINUX_ARM"
    end
    on_intel do
      url "https://github.com/zacesshq/games/releases/download/vVERSION/zacess-games-vVERSION-x86_64-unknown-linux-musl.tar.gz"
      sha256 "SHA256_LINUX_INTEL"
    end
  end

  def install
    bin.install "zacess-games"
  end

  test do
    assert_match "zacess-games", shell_output("#{bin}/zacess-games --version")
    ENV["ZACESS_GAMES_STATE"] = testpath/"state"
    system bin/"zacess-games", "--headless", "trace", "--keys", "right,enter", "--size", "60x20", "--theme", "deep-dark"
  end
end
