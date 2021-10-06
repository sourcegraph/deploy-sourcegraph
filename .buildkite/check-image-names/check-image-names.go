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
	ciimages "github.com/sourcegraph/sourcegraph/enterprise/dev/ci/images"
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
			// Highly doubt anyone would ever want us to traverse git directories.
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

		// for _, image := range matches {
		// 	var count int
		// 	for _, upstream := range ciimages.DeploySourcegraphDockerImages {
		// 		fmt.Printf("testing image: %s from file %s and upstream: %s\n", image, path, upstream)
		// 		if image == upstream {
		// 			fmt.Printf("the count is: %v\n", count)
		// 			count++
		// 			break
		// 		}
		// 	}
		// 	if count < 1 {
		// 		fmt.Printf("image: %s found in %s has no valid match upstream\n", image, path)
		// 		os.Exit(1)
		// 	} else {
		// 		fmt.Printf("Found match for %s in %s\n", image, path)
		// 	}
		// }
		return nil

	})

	matches = Unique(matches)
	for i, image := range matches {
		if image != ciimages.SourcegraphDockerImages[i] {
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
