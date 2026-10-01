class TopoTools < Formula
  include Language::Python::Virtualenv

  desc "DuckDB-powered geospatial topology utilities"
  homepage "https://github.com/OCHA-DAP/topo-tools-py"
  url "https://files.pythonhosted.org/packages/ff/0f/9efcfd72b23a48fc1595165d74a65001f818ba4a955c1e0eea5cbdc3a7da/topo_tools-0.10.2.tar.gz"
  sha256 "a400e0da93f2d5455cf0a9a60c802d8604f0db2b8b46209ed7d52f89b2dafa7a"
  license "MIT"

  depends_on "libyaml"
  depends_on "python@3.14"

  resource "click" do
    url "https://files.pythonhosted.org/packages/c7/0e/7fa0ef50764b67090eca4114772a2abf8b6148198475e54c660b97caeee6/click-8.5.0.tar.gz"
    sha256 "ba0d2089de75ea0310e2dde03160e6ca10009947fb95a182f9b54021bb272e34"
  end

  resource "duckdb" do
    url "https://files.pythonhosted.org/packages/fb/62/a8a30a4c6b94c0861d348ed5633b963f6745a5525527530f02f3c1a7c931/duckdb-1.5.6-cp314-cp314-macosx_10_15_universal2.whl"
    sha256 "aa21d2ad803b2524326e8622d7d96b2bb1ff1d5b60368e1978ee805df9c21fb3"
  end

  resource "psutil" do
    url "https://files.pythonhosted.org/packages/aa/c6/d1ddf4abb55e93cebc4f2ed8b5d6dbad109ecb8d63748dd2b20ab5e57ebe/psutil-7.2.2.tar.gz"
    sha256 "0746f5f8d406af344fd547f1c8daa5f5c33dbc293bb8d6a16d80b4bb88f59372"
  end

  resource "pyyaml" do
    url "https://files.pythonhosted.org/packages/05/8e/961c0007c59b8dd7729d542c61a4d537767a59645b82a0b521206e1e25c2/pyyaml-6.0.3.tar.gz"
    sha256 "d76623373421df22fb4cf8817020cbb7ef15c725b9d5e45f17e189bfc384190f"
  end

  def install
    venv = virtualenv_install_with_resources without: "duckdb"

    # duckdb is pinned to a platform wheel (re-pinned by topo-tools-py's tap workflow on each bump),
    # which Homebrew's resource routing can't install; stage and pip-install it directly.
    resource("duckdb").stage do
      whl = Pathname.pwd/Dir["*.whl"].first
      raise "Expected a .whl file in the staged duckdb resource, found: #{Pathname.pwd.children}" unless whl.exist?

      venv.pip_install whl
    end
  end

  test do
    assert_match "Usage", shell_output("#{bin}/topo-tools --help")
    system libexec/"bin/python3", "-c", "import duckdb; print(duckdb.__version__)"
  end
end
