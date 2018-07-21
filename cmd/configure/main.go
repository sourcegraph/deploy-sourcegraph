package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"os"

	"k8s.io/api/core/v1"
	"k8s.io/api/rbac/v1beta1"
	"k8s.io/client-go/kubernetes/scheme"
)

type configure struct {
	Langservers             []string `json:"langservers"`
	ExperimentalLangservers []string `json:"experimentalLangservers"`

	Gitserver struct {
		Count int `json:"count"`
	} `json:"gitserver"`

	Jaeger struct {
		Enabled bool `json:"enabled"`
	} `json:"jaeger"`

	SiteConfigPath string `json:"siteConfigPath"`
}

func check(err error) {
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func main() {
	flag.Parse()

	configureFile := flag.Arg(0)
	var conf configure
	if configureFile != "" {
		buf, err := ioutil.ReadFile(configureFile)
		check(err)
		check(json.Unmarshal(buf, &conf))
	} else {
		// TODO: interactively build configure.json
		flag.Usage()
		os.Exit(1)
	}

	decode := scheme.Codecs.UniversalDeserializer().Decode
	obj, groupVersionKind, err := decode([]byte(f), nil, nil)

	if err != nil {
		log.Fatal(fmt.Sprintf("Error while decoding YAML object. Err was: %s", err))
	}

	// now use switch over the type of the object
	// and match each type-case
	switch o := obj.(type) {
	case *v1.Pod:
		// o is a pod
	case *v1beta1.Role:
		// o is the actual role Object with all fields etc
	case *v1beta1.RoleBinding:
	case *v1beta1.ClusterRole:
	case *v1beta1.ClusterRoleBinding:
	case *v1.ServiceAccount:
	default:
		//o is unknown for us
	}

}
