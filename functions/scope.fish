function scope -a scope -d "pretty print variables, e.g. `set --global --long | scope`"
    set -l reset (set_color normal)
    set -l red (set_color red)
    set -l green (set_color green)
    set -l blue (set_color blue)
    set -l yellow (set_color yellow)
    set -l cyan (set_color cyan)
    set -l magenta (set_color magenta)
    set -l bold (set_color --bold)
    set -l underline (set_color --underline)
    set -l italic (set_color --italics)

    set -l options h/help # a/align
    if not argparse $options -- $argv
        eval (status function) --help
        return 2
    end

    if set --query _flag_help
        printf "%spretty print variables%s\n" $bold $reset >&2
        printf "\n" >&2
        printf "%sUSAGE:%s\n" $green $reset >&2
        for scope in local function global universal export
            printf "\t" >&2
            echo "set --$scope --long | scope" | fish_indent --ansi
        end
        printf "\n" >&2
        printf "%sOPTIONS:%s\n" $green $reset >&2
        printf "\t%s-h%s, %s--help%s Show this help message\n" $cyan $reset $cyan $reset >&2

        # TODO: add a footer
        return 0
    end

    if isatty stdin
        printf "%serror:%s stdin should be a %spipe%s not a %stty%s\n" $red $reset $bold $reset $red $reset
        printf "try:\n"
        for scope in local function global universal export
            printf "\t"
            echo "set --$scope --long | scope" | fish_indent --ansi
        end
        return 2
    end


    set -l vars
    set -l values
    while read name value
        # Read piped input
        set --append vars $name
        set --append values $value
    end

    for i in (seq (count $vars))
        set -l var $vars[$i]
        test $vars[$i] = history; and continue # Don't print history

        # The output of `set --(local|global|universal) --long` is separated with 2 spaces "  "
        # if there is more than 1 item in the value
        set -l value (string split "  " -- $values[$i])
        set -l n_items (count $value)
        set -l indent ""
        # test $n_items -gt 1; and set indent (string repeat --count 4 " ")

        if test "$value" = ""
            # The variable is defined but has not been assigned a value
            # TODO: make it more clear in the output
            printf "%s%s%s = \n" $red $var $reset
            continue
        else if test $n_items -eq 1
            printf "%s%s%s = " $bold $vars[$i] $reset
        end
        # if test $n_items -gt 1
        #     printf "{\n"
        # end

        for j in (seq $n_items)
            set -l item $value[$j]
            printf "%s" $indent
            if test $n_items -gt 1
                printf "%s%s%s" $bold $var $reset
                printf "[%s%d%s] = " $yellow $j $reset
            end

            if string match --quiet "fish_*color_*" -- $var
                # Assume that the value is a hex color, or another format accepted by `set_color`
                printf "%s%s%s\n" (set_color $value) $value $reset
            else if string match --quiet --regex "^-?\d+\.?\d*\$" -- $item
                # Item is a number like `10` or `34.42`
                printf "%s%s%s\n" $blue $item $reset
            else
                if test "$(string sub --length=1 $item)" = "'" -a "$(string sub --length=1 --start=-1 $item)" = "'"
                    # TODO: why?
                    set item (string sub --start=2 --end=-1 $item)
                end
                if contains -- (string sub --length=1 $item) / "~"
                    # Assume it is a file/directory
                    set item (string replace --regex "^~" "$HOME" -- $item) # test will not expand the `~` to `$HOME`, so we have to do it.
                    # Check if the string is a file path, and if so if it exists on the file system
                    if test -e "$item"
                        printf "%s%s%s (exists %s✓%s)\n" (set_color --bold --italic green) $item $reset $green $reset
                    else
                        printf "%s%s%s (does NOT exist %s✗%s)\n" $red $item $reset $red $reset
                    end
                else
                    printf '%s%s%s\n' $magenta $item $reset
                end
            end
        end

        # if test $n_items -gt 1
        #     printf "}\n"
        # end
    end # | column --table --separater =
    # TODO: figure out how to align properly
end
