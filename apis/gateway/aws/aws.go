package aws

import (
	"context"
	"log"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/ec2"
	"github.com/aws/aws-sdk-go-v2/service/ecs"
)

type ZentAWSConfig struct {
	ecsClient *ecs.Client
	ec2Client *ec2.Client
}

func NewAWS() ZentAWSConfig {

	cf, err := config.LoadDefaultConfig(context.Background(), config.WithRegion("ap-northeast-2"))

	if err != nil {
		log.Fatalln(err)
	}

	ecsClient := ecs.NewFromConfig(cf)
	ec2Client := ec2.NewFromConfig(cf)

	return ZentAWSConfig{
		ecsClient: ecsClient,
		ec2Client: ec2Client,
	}
}
