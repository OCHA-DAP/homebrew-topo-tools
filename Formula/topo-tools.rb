class TopoTools < Formula
  include Language::Python::Virtualenv

  desc "DuckDB-powered geospatial topology utilities"
  homepage "https://github.com/OCHA-DAP/topo-tools"
  url "https://files.pythonhosted.org/packages/ce/3c/b01456ef4e25701855366f9fbed3559f28513a928a0c1cb870434e1fd596/topo_tools-0.18.0.tar.gz"
  sha256 "d9328aff2ab5aa9770155ad1f90374bcebf7c8828bf5593466102d1868a17146"
  license "MIT"

  depends_on "python@3.14"

  on_linux do
    on_intel do
      resource "duckdb-linux" do
        url "https://files.pythonhosted.org/packages/cc/33/01ad2535ee897db2bad70cbc800655167c53afd0b955eed84f0759c2f417/duckdb-2.0.0-cp312-abi3-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl"
        sha256 "ab51ec57d329d6f3df37c0287b55d71c3fc07bb54b61d1afed09104f953b1431"
      end
    end
    on_arm do
      resource "duckdb-linux" do
        url "https://files.pythonhosted.org/packages/92/4a/985fb9d93d7f9f8e82092ddfe05ec8c9a1d0df7bdb0f562a10ced30e3e8f/duckdb-2.0.0-cp312-abi3-manylinux_2_26_aarch64.manylinux_2_28_aarch64.whl"
        sha256 "e38daf0acbad9de7ce892d402b68409519291ee16af3c2cba85ace3b085c7eaa"
      end
    end
  end

  resource "click" do
    url "https://files.pythonhosted.org/packages/c7/0e/7fa0ef50764b67090eca4114772a2abf8b6148198475e54c660b97caeee6/click-8.5.0.tar.gz"
    sha256 "ba0d2089de75ea0310e2dde03160e6ca10009947fb95a182f9b54021bb272e34"
  end

  resource "duckdb" do
    url "https://files.pythonhosted.org/packages/41/28/1fb52f9ea10205a55a07c32e37cd4fd68fa9d1dc2520a12405ec9bb59cac/duckdb-2.0.0-cp312-abi3-macosx_10_15_universal2.whl"
    sha256 "cb1cc30318397c3bcffa6b683196293698052588de3c1ba1e144ba0c72560ce9"
  end

  resource "psutil" do
    url "https://files.pythonhosted.org/packages/aa/c6/d1ddf4abb55e93cebc4f2ed8b5d6dbad109ecb8d63748dd2b20ab5e57ebe/psutil-7.2.2.tar.gz"
    sha256 "0746f5f8d406af344fd547f1c8daa5f5c33dbc293bb8d6a16d80b4bb88f59372"
  end

  def install
    duckdb_resources = OS.mac? ? ["duckdb"] : ["duckdb", "duckdb-linux"]
    venv = virtualenv_install_with_resources without: duckdb_resources

    # duckdb is pinned to platform wheels (re-pinned by topo-tools' tap workflow on each bump),
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
