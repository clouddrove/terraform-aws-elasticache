// Managed By : CloudDrove
// Description : This Terratest is used to test the Terraform Elasticache module.
// Copyright @ CloudDrove. All Right Reserved.
package test

import (
	"testing"
	"github.com/stretchr/testify/assert"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func Test(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		// Source path of Terraform directory.
		TerraformDir: "../../_example/memcached",
		Upgrade: true,
	}

	// This will run 'terraform init' and 'terraform application' and will fail the test if any errors occur
	terraform.InitAndApply(t, terraformOptions)

	// To clean up any resources that have been created, run 'terraform destroy' towards the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// To get the value of an output variable, run 'terraform output'
	Tags := terraform.OutputMap(t, terraformOptions, "tags")

	// Verify we're getting back the outputs we expect
	assert.Equal(t, "test-clouddrove-memcached", Tags["Name"])
}
