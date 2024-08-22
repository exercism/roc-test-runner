app [main] { pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.12.0/Lb8EgiejTUzbggO2HVVuPJFkwvvsfW6LojkLR20kTVE.tar.br" }

import pf.Task exposing [Task]

expect 2 + 2 == 4
expect "four" == "four"

main =
    Task.ok {}
