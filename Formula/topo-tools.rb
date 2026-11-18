class TopoTools < Formula
  include Language::Python::Virtualenv

  desc "DuckDB-powered geospatial topology utilities"
  homepage "https://github.com/OCHA-DAP/topo-tools"
  url "https://files.pythonhosted.org/packages/b2/50/c3aee8f433607d1ef037c7ca9e43dbbafa27722a461beefd496f8ef61152/topo_tools-0.24.0.tar.gz"
  sha256 "9998956d7a60fdd34c72d567a261c7e3f23cd29f27a5fc2292d5207a98a62a49"
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
    url "https://files.pythonhosted.org/packages/45/37/edbf1b0707709013c0cf2e8317e03d97ed29bf4cac709fe328904ae92a38/click-8.5.1.tar.gz"
    sha256 "9bbfada76703fd1d784b83eea012e3e8c6a001a876543ef104fa56aaaeb072b4"
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
