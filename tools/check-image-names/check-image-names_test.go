package main

import (
	"fmt"
	"testing"

	"gotest.tools/v3/assert"
)

func TestCheckImages(t *testing.T) {

	assert.Equal(t, fmt.Errorf("image: foo is not in the upstream list"), CheckImages("tests"))

}
