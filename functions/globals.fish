function globals -d "list all (set --global) variables"
    # TODO: add --help
    set --global --long | scope
end
