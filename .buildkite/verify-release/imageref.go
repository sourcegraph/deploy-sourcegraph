package main

import "fmt"

type ImageReference struct {
	Name     string
	Version  string
	Registry string
	Digest   string
}

func (ir *ImageReference) String() string {
	return fmt.Sprintf("%s: version=%q digest=%q registry=%q", ir.Name, ir.Version, ir.Digest, ir.Registry)
}

func (ir *ImageReference) probablyValid() bool {
	// This function isn't perfect. This is a
	// rough heuristic to probably find
	// Docker image references that are actually
	// the ones that we care about.
	//
	// I wanted to avoid using a specific file schema
	// e.g. parsing a file as K8s or docker-compose, etc.
	//
	// Strings like just "a" are considered to be valid Docker
	// images. I wanted to skip over those for our purposes.
	//

	if ir.Name == "" {
		return false
	}

	noVersion := ir.Version == ""
	noDigest := ir.Digest == ""

	// You can be missing a version or a digest, but not both.
	return noVersion != noDigest
}
