app [main!] {
	pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.22.0/F1JVZPYfWP71s8vk6tHcV1Qx1Ef6CZkwswGoCn8VHZmL.tar.zst",
	#ascii: "https://github.com/Hasnep/roc-ascii/releases/download/v0.4.0/JCHMDr4pEpfo8BAHZjckZ4BWPVRru5umPJXpL5MmhZ7R.tar.zst",
	isodate: "https://github.com/ageron/roc-isodate/releases/download/0.8.1/DZNmAcoruJkepH2QNAzb6SAebPLKy8Nmru8oR4UZHAcr.tar.zst",
	parser: "https://github.com/lukewilliamboswell/roc-parser/releases/download/1.0.2/FrnJ4RGDKpQyoDyESNoBwFNviY4ZGbMVLnUjW9tvSRjk.tar.zst",
	unicode: "https://github.com/roc-lang/unicode/releases/download/4.0.0/3DGC3M4b2pxaRLg4i8cmxWkm2E2WbCPCLntQzf2mkbUV.tar.zst",
}

expect Bool.True

main! = |_args| {
	Ok({})
}
