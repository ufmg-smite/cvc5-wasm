#!/bin/bash

# Use it only when you need to update CVC5 and it's already downloaded. You can 
# also delete CVC5 and let cvc5-wasm re-download it, but this delete all the 
# compiled files then is slower.

git remote add cvcm https://github.com/cvc5/cvc5.git   # only need to do this once per clone
git checkout main   # check out the master branch of your fork
git fetch cvcm --tags -f
git merge --ff-only cvcm/main
git push   # updates cvc5/master into your fork
git checkout - # go back to previous branch