[
  ## Don't run tools concurrently
  parallel: true,

  ## Don't halt the check suite on first failure
  halt_on_error: false,

  ## Tools list (alphabetically ordered)
  tools: [
    ## Compile with warnings as errors
    {:compiler, "mix compile --warnings-as-errors"},

    ## Credo (static code analysis)
    {:credo, "mix credo --strict"},

    ## Check code formatting
    {:formatter, "mix format --check-formatted"},

    ## Run tests
    {:ex_unit, "mix test"},
    {:dialyzer, false},
    {:doctor, false},
    {:ex_doc, false},
    {:gettext, false},
    {:npm_test, false},
    {:sobelow, "mix sobelow --threshold medium"}
  ]
]
