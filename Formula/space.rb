class Space < Formula
  desc "See what takes up your Mac's disk, and clean it safely, from the terminal"
  homepage "https://github.com/romus/space"
  url "https://github.com/romus/space/releases/download/v0.2.0/space-0.2.0-macos-universal.tar.gz"
  sha256 "966a9a236d9f59d728856eb9f6421e5240101b779e91459672262707e5b510ea"
  license "MIT"

  depends_on :macos

  def install
    bin.install "space"
    generate_completions_from_executable(bin/"space", "completion")
  end

  test do
    assert_match "space #{version}", shell_output("#{bin}/space version")
  end
end
