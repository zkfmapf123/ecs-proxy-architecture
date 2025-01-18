package aws

import (
	"context"

	"github.com/aws/aws-sdk-go-v2/service/ec2"
)

func (c ZentAWSConfig) GetEniValue(eni string) string {

	output, err := c.ec2Client.DescribeNetworkInterfaces(context.Background(), &ec2.DescribeNetworkInterfacesInput{
		NetworkInterfaceIds: []string{eni},
	})
	if err != nil {
		return ""
	}

	return *output.NetworkInterfaces[0].Association.PublicIp
}
