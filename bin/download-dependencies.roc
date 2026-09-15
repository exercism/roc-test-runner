app [main!] {
	pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.22.2/9zUBxb1LtXYVc4eR4hAtd1WQDwBYDhM6HQdZz1UFCm2m.tar.zst",
	ascii: "https://github.com/ageron/roc-ascii/releases/download/v0.4.2/3D6JMydSyRWk3oRzG92KaZ6cdqhocn7pvSYehjpuPSvz.tar.zst",
	isodate: "https://github.com/ageron/roc-isodate/releases/download/v0.8.3/9SypUHT4Tn18tJyHyvtt929ByTx15djH3UaKkagRxGwA.tar.zst",
	parser: "https://github.com/lukewilliamboswell/roc-parser/releases/download/1.2.0/GzeZxk7V7GHFa42qhgzd8gUgX6cEyY3NmrwmDfsuskNd.tar.zst",
	random: "https://github.com/kili-ilo/roc-random/releases/download/0.9.2/2ZXLX8WRqrosGu1V3VL5aXqgtfTRvJmjFPx8a26ecVmc.tar.zst",
	unicode: "https://github.com/roc-lang/unicode/releases/download/4.2.0/4W8SHzvwet9hH9qZewJ1J1CVQoH7YKA6zyijWFTB3y1w.tar.zst",
}

expect Bool.True

main! = |_args| {
	Ok({})
}
