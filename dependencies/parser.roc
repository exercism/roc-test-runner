app [] {
	parser: "https://github.com/lukewilliamboswell/roc-parser/releases/download/5.0.0/GWrbcSuoXstBeasuzyfMuXe99zFZFLgBhoWavjA7rteZ.tar.zst",
}

# Keep this separate from packages.roc: declaring unicode there can mask
# the parser package's own pinned Unicode dependency.
# See https://github.com/roc-lang/roc/issues/12738
import parser.Utf8

expect Utf8.parse_str(Utf8.string("é"), "é") == Ok("é")
