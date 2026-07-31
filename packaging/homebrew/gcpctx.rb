class Gcpctx < Formula
  desc "Safe Google Cloud context manager (account, project, ADC, quota)"
  homepage "https://github.com/UriBer/gcpctx"
  url "https://github.com/UriBer/gcpctx/releases/download/v0.3.0/gcpctx-0.3.0.tar.gz"
  sha256 "e4066767aa76c771dc90b679695727e067bea7523f9a847f87f59afc04bbc024"
  license "Apache-2.0"

  depends_on "python@3"

  def install
    # Layout expected by bin/gcpctx package_root(): <prefix>/{bin,lib,shell,VERSION}
    prefix.install "bin", "lib", "shell", "VERSION"
    doc.install "README.md", "LICENSE", "SECURITY.md"
  end

  def caveats
    <<~EOS
      Wire your shell (does not modify profiles during brew install):
        gcpctx shell-setup
      Requires the Google Cloud SDK (`gcloud`) on PATH.
      Optional: pin a trusted binary with GCPCTX_GCLOUD=/absolute/path/to/gcloud
    EOS
  end

  test do
    assert_match "0.3.0", shell_output("#{bin}/gcpctx version")
  end
end
