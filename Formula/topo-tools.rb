class TopoTools < Formula
  include Language::Python::Virtualenv

  desc "DuckDB-powered geospatial topology utilities"
  homepage "https://github.com/OCHA-DAP/topo-tools-py"
  url "https://files.pythonhosted.org/packages/99/ca/781d68f4f305d65ebd0d22f715cf3eb1efd1837dd5198b6eb3170762fd03/topo_tools-0.13.0.tar.gz"
  sha256 "c92e907509835740ef14eef79f29dc7748e8b2261c4097828292965d64cc9dd0"
  license "MIT"

  depends_on "python@3.14"

  on_linux do
    on_intel do
      resource "duckdb-linux" do
        url "https://files.pythonhosted.org/packages/ef/a5/6f8099d9a5a02ddff89e5c85875df3465054845b0920fb0703fbdf8dd2ec/duckdb-1.5.6-cp314-cp314-manylinux_2_26_x86_64.manylinux_2_28_x86_64.whl"
        sha256 "19c5e485e59613b8878d1670bcaa7a010f53c5a4da5ae8e08863e5e529ca6182"
      end
    end
    on_arm do
      resource "duckdb-linux" do
        url "https://files.pythonhosted.org/packages/9d/08/cc510a7952aba69d5cdca17f3ef61c95713d86143f2ee9aa3e097d38f50b/duckdb-1.5.6-cp314-cp314-manylinux_2_26_aarch64.manylinux_2_28_aarch64.whl"
        sha256 "1052b8050ef5696e2c0d8c836949c72f3dd11f0690466acbea739613e8e2750b"
      end
    end
  end

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

  def install
    duckdb_resources = OS.mac? ? ["duckdb"] : ["duckdb", "duckdb-linux"]
    venv = virtualenv_install_with_resources without: duckdb_resources

    # duckdb is pinned to platform wheels (re-pinned by topo-tools-py's tap workflow on each bump),
    # which Homebrew's resource routing can't install; stage and pip-install the one for this OS.
    resource(duckdb_resources.last).stage do
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
