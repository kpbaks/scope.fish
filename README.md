# scope.fish

Pretty print fish variables of a specific scope level.

## Installation
```fish
fisher install kpbaks/scope.fish
```

## Commands
```fish
globals # global variables `set -g`
universals # universal variables `set -U`
exported # environment variables, `set -x`
set --local --long | scope # local variables, `set -l`
set --function --long | scope # function variables `set -f`
```
