app [] {
	parser: "https://github.com/lukewilliamboswell/roc-parser/releases/download/5.0.0/GWrbcSuoXstBeasuzyfMuXe99zFZFLgBhoWavjA7rteZ.tar.zst",
}

# Importing the parser must work offline, including its own Unicode dependency.
import parser.Utf8

expect Utf8.parse_str(Utf8.string("é"), "é") == Ok("é")
