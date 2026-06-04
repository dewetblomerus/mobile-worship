[
  ## Run tools concurrently
  parallel: true,

  ## Tools list (alphabetically ordered)
  tools: [
    ## Compile with warnings as errors
    {:compiler, "mix compile --warnings-as-errors"},

    ## Credo (static code analysis)
    {:credo, "mix credo --strict"},

    ## Check for unused dependencies
    {:deps_unlock, "mix deps.unlock --check-unused"},

    ## Check code formatting
    {:formatter, "mix format --check-formatted"},

    ## Run tests
    {:ex_unit, "mix test"},
    {:dialyzer, false},
    {:doctor, false},
    {:ex_doc, false},
    {:gettext, false},
    {:mix_audit, "mix deps.audit"},
    {:npm_test, false},
    {:sobelow, "mix sobelow --threshold medium"}
  ]
]
