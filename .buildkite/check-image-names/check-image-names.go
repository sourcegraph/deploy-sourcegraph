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
	images "github.com/sourcegraph/sourcegraph/enterprise/dev/ci/images"
)

func main() {

	path := os.Args[1]

	getImages(path)

}

func getImages(dir string) error {

	i := regexp.MustCompile("sourcegraph/[a-z0-9-_.]+:")
	var matches []string

	err := filepath.Walk(dir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if info.IsDir() {
			return nil
		}

		if strings.HasPrefix(path, ".git") {
			return nil
		}

		data, err := ioutil.ReadFile(path)
		if err != nil {
			return errors.Wrap(err, "when reading file contents")
		}

		matchedImages := i.FindAllSubmatch(data, -1)
		for _, match := range matchedImages {
			match := strings.Replace(string(match[0]), "sourcegraph/", "", -1)
			match = strings.Replace(match, ":", "", -1)
			matches = append(matches, match)
		}

		return nil

	})

	matches = Unique(matches)
	for i, image := range matches {
		if image != images.SourcegraphDockerImages[i] {
			fmt.Printf("image: %s was found in is not in the upstream list.\n", image)
		}
	}

	return err

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
