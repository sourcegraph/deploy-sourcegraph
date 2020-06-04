package kube

import (
	"text/tabwriter"
	"tool/cli"
	"tool/file"
	"strings"
)

command: print: {

	task: print: cli.Print & {
		text: tabwriter.Write([
			for x in objects {
				let dir = strings.Join("generated", x.metadata.name)
			},
		])
	}

	task: write: file.Create & {
		filename: "test/foo.txt"
		contents: task.print.text
	}
}
