app [main!] { pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.19.0/Hj-J_zxz7V9YurCSTFcFdu6cQJie4guzsPMUi5kBYUk.tar.br" }

expect 2 + 2 == 4
expect "hello" == "good bye"

main! = |_args|
    Ok({})
