require "fileutils"
require "json"
require "time"

class Deadreckon < Formula
  desc "Long-running, BYOK, sandboxed agentic CLI harness."
  homepage "https://github.com/gregce/deadreckon"
  version "0.8.1"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/gregce/deadreckon/releases/download/v0.8.1/deadreckon-aarch64-apple-darwin.tar.xz"
      sha256 "9587a9cf9ae9205091c2f7378e31ff1a91bdf9e7b52c5f8224bd586a2e437d63"
    end
    if Hardware::CPU.intel?
      url "https://github.com/gregce/deadreckon/releases/download/v0.8.1/deadreckon-x86_64-apple-darwin.tar.xz"
      sha256 "f0f00b1b5bdd6ddb12495779991eca82450fa22c065126837d75ef7916e9e718"
    end
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/gregce/deadreckon/releases/download/v0.8.1/deadreckon-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "392e6703f368d671692c4b2ae0a963dcf1f1e72776f0b7ea6a1e3ceb03b95eaf"
    end
    if Hardware::CPU.intel?
      url "https://github.com/gregce/deadreckon/releases/download/v0.8.1/deadreckon-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "4ccdf8eb7511ac5f8b8c62d8dd3b73ddb18e40f5a9b0044fca7ed6c149255647"
    end
  end
  license "MIT"

  BINARY_ALIASES = {
    "aarch64-apple-darwin": {},
    "aarch64-unknown-linux-gnu": {},
    "x86_64-apple-darwin": {},
    "x86_64-pc-windows-gnu": {},
    "x86_64-unknown-linux-gnu": {}
  }

  def target_triple
    cpu = Hardware::CPU.arm? ? "aarch64" : "x86_64"
    os = OS.mac? ? "apple-darwin" : "unknown-linux-gnu"

    "#{cpu}-#{os}"
  end

  def install_binary_aliases!
    BINARY_ALIASES[target_triple.to_sym].each do |source, dests|
      dests.each do |dest|
        bin.install_symlink bin/source.to_s => dest
      end
    end
  end


  def write_deadreckon_receipt!
    receipt_dir = File.join(Dir.home, ".deadreckon")
    FileUtils.mkdir_p(receipt_dir)
    File.write(
      File.join(receipt_dir, "install-receipt.json"),
      JSON.pretty_generate({
        "channel" => "brew",
        "channel_version" => version.to_s,
        "binary_path" => File.join(bin, "deadreckon"),
        "installed_at" => Time.now.utc.iso8601,
        "install_source" => "brew:gregce/tap/deadreckon",
        "platform_package" => nil,
        "receipt_version" => 1,
      }) + "\n",
    )
  end

  def install
    if OS.mac? && Hardware::CPU.arm?
      bin.install "deadreckon", "dr-capture", "dr-gate", "dr-gate-evaluator-aarch64-unknown-linux-musl", "dr-gate-evaluator-x86_64-unknown-linux-musl"
    end
    if OS.mac? && Hardware::CPU.intel?
      bin.install "deadreckon", "dr-capture", "dr-gate", "dr-gate-evaluator-aarch64-unknown-linux-musl", "dr-gate-evaluator-x86_64-unknown-linux-musl"
    end
    if OS.linux? && Hardware::CPU.arm?
      bin.install "deadreckon", "dr-capture", "dr-gate", "dr-gate-evaluator-aarch64-unknown-linux-musl", "dr-gate-evaluator-x86_64-unknown-linux-musl"
    end
    if OS.linux? && Hardware::CPU.intel?
      bin.install "deadreckon", "dr-capture", "dr-gate", "dr-gate-evaluator-aarch64-unknown-linux-musl", "dr-gate-evaluator-x86_64-unknown-linux-musl"
    end

    install_binary_aliases!

    write_deadreckon_receipt!

    # Homebrew will automatically install these, so we don't need to do that
    doc_files = Dir["README.*", "readme.*", "LICENSE", "LICENSE.*", "CHANGELOG.*"]
    leftover_contents = Dir["*"] - doc_files

    # Install any leftover files in pkgshare; these are probably config or
    # sample files.
    pkgshare.install(*leftover_contents) unless leftover_contents.empty?
  end
end
