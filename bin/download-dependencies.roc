app [main!] {
    pf: platform "https://github.com/lukewilliamboswell/roc-platform-template-zig/releases/download/0.9/8GdFEvQYS3TeAZxKvTzCLVdQiomweGtXcdZkXNDEeABq.tar.zst",
    #isodate: "https://github.com/imclerran/roc-isodate/",  # TODO: update to latest release
    #json: "https://github.com/lukewilliamboswell/roc-json/",  # TODO: update to latest release
    #parser: "https://github.com/lukewilliamboswell/roc-parser/",  # TODO: update to latest release
    #unicode: "https://github.com/roc-lang/unicode/",  # TODO: update to latest release
}

expect Bool.True

main! = |_args| {
    Ok({})
}
