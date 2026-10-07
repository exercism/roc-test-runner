# A platform test app, with a multiline header.
app [main!] {
	pf: platform "https://github.com/ageron/roc-parallel/releases/download/0.3.0/ArsAKsVYCn93y2GdXRuMDN5DRrVyb8Fa8BJ3QtxqFxfF.tar.zst",
}

import pf.Parallel

main! : List(Str) => Try({}, [Exit(I8)])
main! = |_args| {
	match Parallel.map!([3.U64, 1, 2], { workers: 2, task: |n| n * 10 }) {
		Ok([30, 10, 20]) => Ok({})
		_ => Err(Exit(1))
	}
}
