app [main!] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.21.0/4rAQg8kUYZ3Vksr4qMQHpaFYNiHSn9GgS7gVxghd1XYV.tar.zst",
    isodate: "https://github.com/ageron/roc-isodate/releases/download/0.8.0/B2h6tefXQtEz9VG6QukLDBoGXhRtwGLj9sZHDEJaTHkS.tar.zst",
    parser: "https://github.com/lukewilliamboswell/roc-parser/releases/download/0.11.0/HS5cXN8JrJKdxM2Y8azXzbHCxCx2qxocySTGr6sLGQTZ.tar.zst",
    unicode: "https://github.com/roc-lang/unicode/releases/download/2.0.0/9ZvqNzsNkpqFmGTeATAY3BNBD7mP41jqZx2w2N19tBvh.tar.zst",
}

expect Bool.True

main! = |_args| {
    Ok({})
}
