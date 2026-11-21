# A platform test app, with a multiline header.
app [main!] {
	pf: platform "https://github.com/ageron/roc-parallel/releases/download/0.4.0/DqdrrdJ5VUDxWN2tfJmrkC7oLzpzGK9vhPVa1C1yTvGc.tar.zst",
}

import pf.Parallel

main! : List(Str) => Try({}, [Exit(I8)])
main! = |_args| {
	match Parallel.map!([3.U64, 1, 2], { workers: 2, task: |n| n * 10 }) {
		Ok([30, 10, 20]) => Ok({})
		_ => Err(Exit(1))
	}
}
