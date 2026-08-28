app [main!] {
	pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.22.0/F1JVZPYfWP71s8vk6tHcV1Qx1Ef6CZkwswGoCn8VHZmL.tar.zst",
	ascii: "https://github.com/ageron/roc-ascii/releases/download/v0.4.2/3D6JMydSyRWk3oRzG92KaZ6cdqhocn7pvSYehjpuPSvz.tar.zst",
	isodate: "https://github.com/ageron/roc-isodate/releases/download/v0.8.3/9SypUHT4Tn18tJyHyvtt929ByTx15djH3UaKkagRxGwA.tar.zst",
	parser: "https://github.com/lukewilliamboswell/roc-parser/releases/download/1.1.0/AcowGJvjA8U2gCEf7E8QYNUePBdw7dzdRqSvERKaJZ53.tar.zst",
	unicode: "https://github.com/roc-lang/unicode/releases/download/4.0.0/3DGC3M4b2pxaRLg4i8cmxWkm2E2WbCPCLntQzf2mkbUV.tar.zst",
}

expect Bool.True

main! = |_args| {
	Ok({})
}
