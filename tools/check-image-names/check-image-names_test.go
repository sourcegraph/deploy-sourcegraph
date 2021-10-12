package main

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestCheckImages(t *testing.T) {

	errorString := "image: foo is not in the upstream list"
	err := CheckImages("tests")
	assert.NotNil(t, err)
	assert.Contains(t, err.Error(), errorString)

}
