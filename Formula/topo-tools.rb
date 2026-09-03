class TopoTools < Formula
  include Language::Python::Virtualenv

  desc "DuckDB-powered geospatial topology utilities"
  homepage "https://github.com/OCHA-DAP/topo-tools-py"
  url "https://files.pythonhosted.org/packages/31/ea/ced6cef9d59834edc6103dd33c1a0907608de54441852299faa6a352647c/topo_tools-0.5.6.tar.gz"
  sha256 "ca0694259f8fe9a691b5b4abc889a323ea71afd4c54b1ead5a887b89ab9d8167"
  license "MIT"

  depends_on "libyaml"
  depends_on "python@3.14"

  resource "click" do
    url "https://files.pythonhosted.org/packages/c7/0e/7fa0ef50764b67090eca4114772a2abf8b6148198475e54c660b97caeee6/click-8.5.0.tar.gz"
    sha256 "ba0d2089de75ea0310e2dde03160e6ca10009947fb95a182f9b54021bb272e34"
  end

  # Pinned to a prebuilt wheel, not the sdist; topo-tools-py's homebrew-tap
  # workflow keeps this in sync on every version bump.
  resource "duckdb" do
    url "https://files.pythonhosted.org/packages/3e/56/12c65bfa2d2605b81981b264788891bcf11ec72227889554cead5d8d13b9/duckdb-1.5.5-cp314-cp314-macosx_10_15_universal2.whl"
    sha256 "8e6413dd40facb7b8ab21bd844450cd8f549b29e138635be9cf090ef4d2049e2"
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

    # duckdb's wheel isn't a py3-none-any wheel, so Homebrew's automatic
    # resource routing can't install it; stage and pip-install it directly.
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
