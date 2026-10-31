app [] {
	parser: "https://github.com/lukewilliamboswell/roc-parser/releases/download/3.0.0/6xsRdRqenJrAb4wG7HaST4Xh349vD5sHAJDsKTK6E3dr.tar.zst",
}

# Keep this separate from packages.roc: declaring unicode there can mask
# the parser package's own pinned Unicode dependency.
# See https://github.com/roc-lang/roc/issues/12738
import parser.Utf8

expect Utf8.parse_str(Utf8.string("é"), "é") == Ok("é")
