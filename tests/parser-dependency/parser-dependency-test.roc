app [] {
	parser: "https://github.com/lukewilliamboswell/roc-parser/releases/download/3.0.0/6xsRdRqenJrAb4wG7HaST4Xh349vD5sHAJDsKTK6E3dr.tar.zst",
}

# Importing the parser must work offline, including its own Unicode dependency.
import parser.Utf8

expect Utf8.parse_str(Utf8.string("é"), "é") == Ok("é")
