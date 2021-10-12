package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"

	"github.com/pkg/errors"
	"github.com/sourcegraph/sourcegraph/enterprise/dev/ci/images"
)

var (
	i       = regexp.MustCompile(`index\.docker\.io\/sourcegraph/(?P<image>[a-z0-9-_.]+):[a-z0-9-_]+@sha256:[[:alnum:]]+`)
	matches []string
	data    []byte
)

func main() {

	path := os.Args[1]

	fmt.Print(CheckImages(path))

}

func CheckImages(path string) error {

	err := filepath.Walk(path, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			fmt.Println(err)
			return err
		}
		if info.IsDir() {
			return nil
		}

		if strings.HasPrefix(path, ".git") {
			return nil
		}

		data, err = ioutil.ReadFile(path)
		if err != nil {
			return errors.Wrap(err, "when reading file contents")
		}

		// matchedImages contains all lines matching our regex. FindAllSubmatch returns
		// a slice containing the full string, and the capture group `image` for each image in a file.
		// We then loop over each slice, pull out the capture group and append it to a list of images
		// to compare with upstream.
		matchedImages := i.FindAllSubmatch(data, -1)
		for _, match := range matchedImages {
			matchd := string(match[1])
			matches = append(matches, matchd)
		}

		return nil
	})
	matches = Unique(matches)
	for i, image := range matches {
		if image != images.DeploySourcegraphDockerImages[i] {
			return fmt.Errorf("image: %s is not in the upstream list", image)
		}
	}

	if err != nil {
		fmt.Println(err)
	}

	return nil

}

func Unique(strSlice []string) []string {
	keys := make(map[string]bool)
	list := []string{}
	for _, entry := range strSlice {
		if _, found := keys[entry]; !found {
			keys[entry] = true
			list = append(list, entry)
		}
	}

	sort.Strings(list)

	return list
}
