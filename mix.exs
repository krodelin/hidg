defmodule Hidg.MixProject do
  use Mix.Project

  @app :hidg

  def project do
    [
      app: @app,
      version: "0.0.1",
      elixir: "~> 1.4",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      make_clean: ["clean"],
      compilers: [:elixir_make | Mix.compilers()],
      deps: deps(),
      docs: [extras: ["README.md"], main: "readme"]
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:elixir_make, "~> 0.5.2"}
      # {:ex_doc, "~> 0.18", only: :dev}
    ]
  end

  defp description do
    "Elixir interface to Linux HID Gadget devices"
  end

  defp package do
    [
      maintainers: ["Udo Schneider"],
      files: ["lib", "LICENSE", "mix.exs", "README.md", "src/*.[ch]", "Makefile"],
      licenses: ["Apache 2.0"],
      links: %{"Github" => "https://github.com/krodelin/#{@app}"}
    ]
  end

end
