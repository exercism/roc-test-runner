app [main!] { pf: platform "https://github.com/ageron/roc-parallel/releases/download/0.3.0/ArsAKsVYCn93y2GdXRuMDN5DRrVyb8Fa8BJ3QtxqFxfF.tar.zst" }

main! : List(Str) => Try({}, [Exit(I8), TestsFailed({ passed : U64, failed : U64 })])
main! = |_args| {
	Err(TestsFailed({ passed: 1, failed: 2 }))
}
