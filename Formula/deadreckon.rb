require "fileutils"
require "json"
require "time"

class Deadreckon < Formula
  desc "Long-running, BYOK, sandboxed agentic CLI harness."
  homepage "https://github.com/gregce/deadreckon"
  version "0.8.3"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/gregce/deadreckon/releases/download/v0.8.3/deadreckon-aarch64-apple-darwin.tar.xz"
      sha256 "5a2e94297950106c65c4848c44a38f7da714578973a9c3f64eebcad18d9afd18"
    end
    if Hardware::CPU.intel?
      url "https://github.com/gregce/deadreckon/releases/download/v0.8.3/deadreckon-x86_64-apple-darwin.tar.xz"
      sha256 "11b641bb356c69643ef1ffbd13fc72a6ff179dc738cd42e60e69f21a9e3f7f83"
    end
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/gregce/deadreckon/releases/download/v0.8.3/deadreckon-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "18042624d27ae220ccabcc6737a4daf0e04c47e81cb0d43c33b6f32931373b28"
    end
    if Hardware::CPU.intel?
      url "https://github.com/gregce/deadreckon/releases/download/v0.8.3/deadreckon-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "68f8d574b78be28df303ab7c680151961738cc0194879fcb4771296cfb90d74c"
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
