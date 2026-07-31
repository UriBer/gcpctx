class Gcpctx < Formula
  desc "Safe Google Cloud context manager (account, project, ADC, quota)"
  homepage "https://github.com/UriBer/gcpctx"
  url "https://github.com/UriBer/gcpctx/releases/download/v0.3.0/gcpctx-0.3.0.tar.gz"
  sha256 "REPLACE_WITH_RELEASE_SHA256"
  license "Apache-2.0"

  depends_on "python@3"

  def install
    bin.install "bin/gcpctx"
    lib.install Dir["lib/*"]
    # Keep lib next to bin for package_root resolution — install tree:
    prefix.install "lib"
    (prefix/"shell").install Dir["shell/*"]
    (prefix/"VERSION").write "0.3.0"
    doc.install "README.md", "LICENSE", "SECURITY.md"
  end

  def caveats
    <<~EOS
      Wire your shell (does not modify profiles during brew install):
        gcpctx shell-setup
      Requires the Google Cloud SDK (`gcloud`) on PATH.
    EOS
  end

  test do
    assert_match "0.3.0", shell_output("#{bin}/gcpctx version")
  end
end
