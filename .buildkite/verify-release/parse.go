package main

import (
	_ "crypto/sha256"

	"fmt"
	"strings"

	"verify-release/reference"
)

func Parse(line string) *ImageReference {
	segments := strings.Fields(line)
	for _, s := range segments {
		if probablyComment(s) {
			return nil
		}

		s = trimQuotes(s)
		imgRef := parseSegment(s)
		if imgRef != nil && imgRef.probablyValid() {
			return imgRef
		}
	}

	return nil
}

func parseSegment(s string) *ImageReference {
	r, err := reference.Parse(s)
	if err != nil {
		return nil
	}

	imgRef := &ImageReference{}
	named, ok := r.(reference.Named)
	if !ok {
		return nil
	}

	path := reference.Path(named)
	imgRef.Name = path

	if tagged, ok := r.(reference.Tagged); ok {
		imgRef.Version = tagged.Tag()
	}

	d := reference.Domain(named)
	imgRef.Registry = d

	if domainIsNotHostName(d) {
		imgRef.Name = fmt.Sprintf("%s/%s", d, path)
		imgRef.Registry = ""
	}

	if digested, ok := r.(reference.Digested); ok {
		d := digested.Digest().String()
		imgRef.Digest = strings.TrimPrefix(d, "sha256:")
	}

	return imgRef
}

func probablyComment(s string) bool {
	return strings.HasPrefix(s, "#")
}

// trimQuotes removes surrounding single or double
// quotes around "s"
func trimQuotes(s string) string {
	for _, quote := range []byte{'"', '\''} {
		if len(s) > 1 {
			if s[0] == quote && s[len(s)-1] == byte(quote) {
				return s[1 : len(s)-1]
			}
		}
	}

	return s
}

// copied from https://github.com/retrohacker/parse-docker-image-name/blob/1d43ab3bde106d77374530b1d982d47375742672/index.js#L3
var (
	hasPort     = reference.Match(":[0-9]+")
	hasDot      = reference.Match("\\.")
	isLocalhost = reference.Match("^localhost(:[0-9]+)?$")
)

func domainIsNotHostName(s string) bool {
	return s != "" && !hasPort.MatchString(s) && !hasDot.MatchString(s) && !isLocalhost.MatchString(s)
}
