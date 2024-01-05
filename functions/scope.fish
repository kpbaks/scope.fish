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

    if isatty stdin
        printf "%serror:%s stdin should be a %spipe%s not a %stty%s\n" $red $reset $bold $reset $red $reset
        printf "try:\n"
        for scope in local function global universal
            printf "\t"
            echo "set --$scope --long | scope" | fish_indent --ansi
        end
        return 2
    end

    set -l vars
    set -l values
    while read name value
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
        test $n_items -gt 1; and set indent (string repeat --count 4 " ")

        if test "$value" = ""
            # The variable is defined but has not been assigned a value
            printf "%s%s%s = \n" $red $var $reset
            continue
        else
            printf "%s%s%s = " $bold $vars[$i] $reset
        end
        if test $n_items -gt 1
            printf "{\n"
        end

        for j in (seq $n_items)
            # set -l value $values[$i]
            set -l item $value[$j]
            printf "%s" $indent
            test $n_items -gt 1; and printf "[%s%d%s] = " $yellow $j $reset
            if string match --quiet "fish_*color_*" -- $var
                # Assume that the value is a hex color
                printf "%s%s%s\n" (set_color $value) $value $reset
            else if string match --quiet --regex "^-?\d+\.?\d*\$" -- $item
                # Item is a digit
                printf "%s%s%s\n" $blue $item $reset
            else
                # TODO: check if the string is a file path, and if so if it exists on the file system
                printf '%s%s%s\n' $green $item $reset
            end
        end

        if test $n_items -gt 1
            printf "}\n"
        end
    end
end
