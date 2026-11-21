app [main!] { pf: platform "https://github.com/ageron/roc-parallel/releases/download/0.4.0/DqdrrdJ5VUDxWN2tfJmrkC7oLzpzGK9vhPVa1C1yTvGc.tar.zst" }

main! : List(Str) => Try({}, [Exit(I8), TestsFailed({ passed : U64, failed : U64 })])
main! = |_args| {
	Err(TestsFailed({ passed: 1, failed: 2 }))
}
