app [main!] { pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.20.0/X73hGh05nNTkDHU06FHC0YfFaQB1pimX7gncRcao5mU.tar.br" }

expect 2 + 2 == 4
expect "hello" == "good bye"

main! = |_args|
    Ok({})
