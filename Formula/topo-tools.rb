class TopoTools < Formula
  include Language::Python::Virtualenv

  desc "DuckDB-powered geospatial topology utilities"
  homepage "https://github.com/OCHA-DAP/topo-tools"
  url "https://files.pythonhosted.org/packages/a3/2a/b042a81fd6af4a7500d523b6b0d5f7b4d66463a3425bd00c8a45474f1c09/topo_tools-0.26.2.tar.gz"
  sha256 "688340f1955e01868caa6ef5783a41f1b7185b2bf89c40b70d5f4c4417e8ee50"
  license "MIT"

  depends_on "python@3.14"

  on_linux do
    on_intel do
      resource "duckdb-linux" do
        url "https://files.pythonhosted.org/packages/0d/3e/da0560077b09e964a42c9e4ec735610aaf24e8f010aa46d33c3ef62760e1/duckdb-2.0.1-cp312-abi3-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl"
        sha256 "39ffeb136abed770a496e5592a464f18a07b1543e7ddb1ff6453215e179f1647"
      end
    end
    on_arm do
      resource "duckdb-linux" do
        url "https://files.pythonhosted.org/packages/2c/d2/65e72713f60b02d93798f012faedf364e9cbc5e6b7ef123392872f779dfe/duckdb-2.0.1-cp312-abi3-manylinux_2_26_aarch64.manylinux_2_28_aarch64.whl"
        sha256 "ba06918b64d4061bd9ed722dc10adf66f9a10f96426e2403db93a36f590ba3dc"
      end
    end
  end

  resource "click" do
    url "https://files.pythonhosted.org/packages/45/37/edbf1b0707709013c0cf2e8317e03d97ed29bf4cac709fe328904ae92a38/click-8.5.1.tar.gz"
    sha256 "9bbfada76703fd1d784b83eea012e3e8c6a001a876543ef104fa56aaaeb072b4"
  end

  resource "duckdb" do
    url "https://files.pythonhosted.org/packages/49/d8/ebb8ff07c617d1a8c25e7f7718a6955d2d5f7e539ec5219be1da478c0a42/duckdb-2.0.1.tar.gz"
    sha256 "5b3f493140e35b75298ee0fc606d98e3065e8601e64fe81b09326de7a6fd68e0"
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
