# A platform test app, with a multiline header.
app [main!] {
	pf: platform "https://github.com/ageron/roc-parallel/releases/download/0.4.0/DqdrrdJ5VUDxWN2tfJmrkC7oLzpzGK9vhPVa1C1yTvGc.tar.zst",
}

import pf.Parallel
import pf.Stderr

main! : List(Str) => Try({}, [Exit(I8), WorkerError([InvalidWorkerCount])])
main! = |_args| {
	actual = Parallel.map!([3.U64], { workers: 2, task: |n| n * 10 }) ? WorkerError
	if actual != [99] {
		Stderr.line!("wrong total: expected [99], actual [30] (workers: 2)")
		Stderr.line!("0 passed, 1 failed")
		return Err(Exit(1))
	}
	Ok({})
}
