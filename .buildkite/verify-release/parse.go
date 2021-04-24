package main

import (
	"bufio"
	_ "crypto/sha256"
	"io"

	"fmt"
	"strings"

	"verify-release/reference"
)

func Parse(r io.Reader) []*ImageReference {
	var out []*ImageReference

	scanner := bufio.NewScanner(r)
	scanner.Split(bufio.ScanLines)

	for scanner.Scan() {
		imgRef := ParseLine(scanner.Text())
		if imgRef != nil {
			out = append(out, imgRef)
		}
	}

	return out
}

func ParseLine(line string) *ImageReference {
	line = trimComment(line)

	segments := strings.Fields(line)
	for _, s := range segments {
		s = trimQuotes(s)
		imgRef := parseSegment(s)

		if imgRef != nil && imgRef.probablyValid() {
			return imgRef
		}
	}

	return nil
}

func trimComment(line string) string {
	// assume any appearance of "#" is a comment
	i := strings.LastIndex(line, "#")
	if i >= 0 {
		line = line[:i]
	}

	return line
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
