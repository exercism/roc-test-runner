app [main!] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.20.0/X73hGh05nNTkDHU06FHC0YfFaQB1pimX7gncRcao5mU.tar.br",
    isodate: "https://github.com/imclerran/roc-isodate/releases/download/v0.6.2/73w_H-aSJNcWqtXvMG4JQw_HoaApMBLnE92XD4OcVGU.tar.br",
    json: "https://github.com/lukewilliamboswell/roc-json/releases/download/0.13.0/RqendgZw5e1RsQa3kFhgtnMP8efWoqGRsAvubx4-zus.tar.br",
    parser: "https://github.com/lukewilliamboswell/roc-parser/releases/download/0.10.0/6eZYaXkrakq9fJ4oUc0VfdxU1Fap2iTuAN18q9OgQss.tar.br",
    unicode: "https://github.com/roc-lang/unicode/releases/download/0.3.0/9KKFsA4CdOz0JIOL7iBSI_2jGIXQ6TsFBXgd086idpY.tar.br",
}

expect Bool.true

main! = |_args|
    Ok({})
