class Space < Formula
  desc "See what takes up your Mac's disk, and clean it safely, from the terminal"
  homepage "https://github.com/romus/space"
  url "https://github.com/romus/space/releases/download/v0.1.2/space-0.1.2-macos-universal.tar.gz"
  sha256 "d327cc1b0759968f7503239603e3c55a8dba8bcbaaccfeb5bb9dfdc62c4f2a74"
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
