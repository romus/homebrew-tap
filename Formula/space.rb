class Space < Formula
  desc "See what takes up your Mac's disk, and clean it safely, from the terminal"
  homepage "https://github.com/romus/space"
  url "https://github.com/romus/space/releases/download/v0.1.1/space-0.1.1-macos-universal.tar.gz"
  sha256 "b14dbb50ecb5f882c0b9107e6c378c3617a700c1ac628a6d6a90e8067ed5328b"
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
