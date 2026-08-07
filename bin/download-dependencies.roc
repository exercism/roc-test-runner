app [main!] {
	pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.21.0/4rAQg8kUYZ3Vksr4qMQHpaFYNiHSn9GgS7gVxghd1XYV.tar.zst",
	isodate: "https://github.com/ageron/roc-isodate/releases/download/0.8.0/B2h6tefXQtEz9VG6QukLDBoGXhRtwGLj9sZHDEJaTHkS.tar.zst",
	parser: "https://github.com/lukewilliamboswell/roc-parser/releases/download/1.0.2/FrnJ4RGDKpQyoDyESNoBwFNviY4ZGbMVLnUjW9tvSRjk.tar.zst",
	unicode: "https://github.com/roc-lang/unicode/releases/download/3.0.0/ACj5ceJnEY6vaejuQArN1naVzcxeThATZrKYYgzJCZJ5.tar.zst",
}

expect Bool.True

main! = |_args| {
	Ok({})
}
