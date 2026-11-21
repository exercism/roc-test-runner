# A platform test app, with a multiline header.
app [main!] {
	pf: platform "https://github.com/ageron/roc-parallel/releases/download/0.4.0/DqdrrdJ5VUDxWN2tfJmrkC7oLzpzGK9vhPVa1C1yTvGc.tar.zst",
}

import pf.Parallel

main! : List(Str) => Try({}, [Exit(I8)])
main! = |_args| {
	"not an exit code"
}
