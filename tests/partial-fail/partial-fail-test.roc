app [main!] { pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.19.0/bi5zubJ-_Hva9vxxPq4kNx4WHX6oFs8OP6Ad0tCYlrY.tar.br" }

expect 2 + 2 == 4
expect "hello" == "good bye"

main! = |_args|
    Ok({})
