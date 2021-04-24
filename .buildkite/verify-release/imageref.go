package main

type ImageReference struct {
	Name     string
	Version  string
	Registry string
	Digest   string
}

func (ir *ImageReference) probablyValid() bool {
	// This function isn't perfect, this is a
	// rough heuristic to probably find
	// docker images references
	// that are actually the one that we care about.
	//
	// I wanted to avoid using a specific file schema
	// e.g. parsing a file as K8s or docker-compose, etc.
	//
	// Strings like "a" are considered to be valid docker
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
