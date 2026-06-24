require "fileutils"
require "json"
require "time"

class Deadreckon < Formula
  desc "Long-running, BYOK, sandboxed agentic CLI harness."
  homepage "https://github.com/gregce/deadreckon"
  version "0.3.1"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/gregce/deadreckon/releases/download/v0.3.1/deadreckon-aarch64-apple-darwin.tar.xz"
    end
    if Hardware::CPU.intel?
      url "https://github.com/gregce/deadreckon/releases/download/v0.3.1/deadreckon-x86_64-apple-darwin.tar.xz"
    end
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/gregce/deadreckon/releases/download/v0.3.1/deadreckon-aarch64-unknown-linux-gnu.tar.xz"
    end
    if Hardware::CPU.intel?
      url "https://github.com/gregce/deadreckon/releases/download/v0.3.1/deadreckon-x86_64-unknown-linux-gnu.tar.xz"
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
      bin.install "deadreckon", "dr-gate"
    end
    if OS.mac? && Hardware::CPU.intel?
      bin.install "deadreckon", "dr-gate"
    end
    if OS.linux? && Hardware::CPU.arm?
      bin.install "deadreckon", "dr-gate"
    end
    if OS.linux? && Hardware::CPU.intel?
      bin.install "deadreckon", "dr-gate"
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
