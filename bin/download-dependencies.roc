app [main] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.15.0/SlwdbJ-3GR7uBWQo6zlmYWNYOxnvo8r6YABXD-45UOw.tar.br",
    isodateOld: "https://github.com/imclerran/roc-isodate/releases/download/v0.5.0/ptg0ElRLlIqsxMDZTTvQHgUSkNrUSymQaGwTfv0UEmk.tar.br",
    isodate: "https://github.com/imclerran/roc-isodate/releases/download/v0.5.1/XHx5wx95nuICKpN8sxMwYnCme5oX_YFbJUL1s6D1feU.tar.br",
    json: "https://github.com/lukewilliamboswell/roc-json/releases/download/0.10.2/FH4N0Sw-JSFXJfG3j54VEDPtXOoN-6I9v_IA8S18IGk.tar.br",
    parser: "https://github.com/lukewilliamboswell/roc-parser/releases/download/0.7.2/1usTzOOACTpnkarBX0ED3gFESzR4ROdAlt1Llf4WFzo.tar.br",
    rand: "https://github.com/lukewilliamboswell/roc-random/releases/download/0.3.0/hPlOciYUhWMU7BefqNzL89g84-30fTE6l2_6Y3cxIcE.tar.br",
    unicode: "https://github.com/roc-lang/unicode/releases/download/0.1.2/vH5iqn04ShmqP-pNemgF773f86COePSqMWHzVGrAKNo.tar.br",
}

expect Bool.true

main =
    Task.ok {}
