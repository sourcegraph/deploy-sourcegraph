package kube

import (
	"text/tabwriter"
	"tool/cli"
	"tool/file"
)

command: ls: {
	task: print: cli.Print & {
		text: tabwriter.Write([
			for x in objects {
				"\(x.kind) \t\(x.metadata.name)"
			},
		])
	}

	task: write: file.Create & {
		filename: "test/foo.txt"
		contents: task.print.text
	}
}
