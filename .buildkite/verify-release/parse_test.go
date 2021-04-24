package main

import (
	_ "crypto/sha256"
	"testing"

	"github.com/google/go-cmp/cmp"
)

func TestParse(t *testing.T) {
	for _, test := range []struct {
		line     string
		expected *ImageReference
	}{
		{
			line: "sourcegraph:3.20",
			expected: &ImageReference{
				Name:    "sourcegraph",
				Version: "3.20",
			},
		},

		{
			line: "sourcegraph:insiders",
			expected: &ImageReference{
				Name:    "sourcegraph",
				Version: "insiders",
			},
		},

		{
			line: "sourcegraph/frontend:3.20",
			expected: &ImageReference{
				Name:    "sourcegraph/frontend",
				Version: "3.20",
			},
		},

		{
			line: "index.docker.io/sourcegraph/frontend:3.20",
			expected: &ImageReference{
				Name:     "sourcegraph/frontend",
				Version:  "3.20",
				Registry: "index.docker.io",
			},
		},

		{
			line: "sourcegraph/frontend@sha256:939125d442dc324f811af78f74a5fc97708bd80094eb6b233784fa0415f07fed",
			expected: &ImageReference{
				Name:   "sourcegraph/frontend",
				Digest: "939125d442dc324f811af78f74a5fc97708bd80094eb6b233784fa0415f07fed",
			},
		},

		{
			line: "frontend@sha256:939125d442dc324f811af78f74a5fc97708bd80094eb6b233784fa0415f07fed",
			expected: &ImageReference{
				Name:   "frontend",
				Digest: "939125d442dc324f811af78f74a5fc97708bd80094eb6b233784fa0415f07fed",
			},
		},

		{
			line: "\"sourcegraph:3.20\"",
			expected: &ImageReference{
				Name:    "sourcegraph",
				Version: "3.20",
			},
		},

		{
			line: "'sourcegraph:3.20'",
			expected: &ImageReference{
				Name:    "sourcegraph",
				Version: "3.20",
			},
		},

		{
			line: "'sourcegraph:3.20' \\# a comment...",
			expected: &ImageReference{
				Name:    "sourcegraph",
				Version: "3.20",
			},
		},

		{
			line: "- image: 'sourcegraph:3.20'",
			expected: &ImageReference{
				Name:    "sourcegraph",
				Version: "3.20",
			},
		},

		{
			line:     "#leadingcomment 'sourcegraph:3.20'",
			expected: nil,
		},

		{
			line: "'sourcegraph:3.20'#yolo",
			expected: &ImageReference{
				Name:    "sourcegraph",
				Version: "3.20",
			},
		},

		{
			line:     "\\#sourcegraph:3.20 \\# a comment...",
			expected: nil,
		},

		{
			line:     "sourcegraph",
			expected: nil,
		},

		{
			line:     "https://sourcegraph.com",
			expected: nil,
		},

		{
			line:     "",
			expected: nil,
		},
	} {
		t.Run(test.line, func(t *testing.T) {
			image := Parse(test.line)
			equalReference(t, test.expected, image)
		})
	}

}

func equalReference(t *testing.T, expected, actual *ImageReference) {
	t.Helper()

	diff := cmp.Diff(expected, actual)
	if diff != "" {
		t.Errorf("unequal image references (-expected +actual):\n%s", diff)
	}
}
