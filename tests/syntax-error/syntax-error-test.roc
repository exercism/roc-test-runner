app [main] { cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.14.0/dC5ceT962N_4jmoyoffVdphJ_4GlW3YMhAPyGPr-nU0.tar.br" }

iMpOrT cli.Task exposing [Task]

expect 2 + 2 == 5
expect "four" == "five"

main =
    Task.ok {}
