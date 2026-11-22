cask "writeless" do
  version "2.1.1"
  sha256 "5cd8b6ede66e41de064a710f3de4e1aa637ad4ddb6caabcebbde11f0eb0ce3be"

  url "https://github.com/romus/writeless-macos/releases/download/v#{version}/Writeless-#{version}.zip"
  name "Write Less"
  desc "On-device speech-to-text from the menu bar"
  homepage "https://github.com/romus/writeless-macos"

  depends_on arch: :arm64
  depends_on macos: :sonoma

  app "Write Less.app"

  # Releases are ad-hoc signed, so their code signature changes with every
  # build and Homebrew cannot carry the Gatekeeper approval across upgrades.
  # Without this, every update means another trip to Privacy & Security.
  # Remove this block once releases are signed with a stable identity.
  postflight_steps do
    run "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "{{appdir}}/Write Less.app"]
  end

  uninstall quit: "dev.romus.writeless"

  zap trash: [
    "~/Library/Application Support/Writeless",
    "~/Library/Caches/dev.romus.writeless",
    "~/Library/HTTPStorages/dev.romus.writeless",
    "~/Library/Preferences/dev.romus.writeless.plist",
  ]

  caveats <<~CAVEATS
    Write Less needs Microphone access on first launch, to record.

    Each transcript goes to the clipboard — press ⌘V to paste it.

    It downloads its speech model (about 630 MB) on first launch.
  CAVEATS
end
