class Space < Formula
  desc "See what takes up your Mac's disk, and clean it safely, from the terminal"
  homepage "https://github.com/romus/space"
  url "https://github.com/romus/space/releases/download/v0.1.0/space-0.1.0-macos-universal.tar.gz"
  sha256 "7a0d5569ab9e061fb1cb35b55fa77e5ce4f9195bddc3da4603c492c2cbaaa445"
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
