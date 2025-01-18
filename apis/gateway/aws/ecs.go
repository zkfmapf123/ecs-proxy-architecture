package aws

import (
	"context"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/ecs"
)

type ecsTaskAttrParams struct {
	eniId string
}

func (c ZentAWSConfig) GetContainerPublicIP(cluster, service string) ([]string, error) {

	taskArns, err := c.getECSTaskArns(cluster, service)
	if err != nil {
		return nil, err
	}

	taskAttr, err := c.getTaskAttr(cluster, taskArns)
	if err != nil {
		return nil, err
	}

	publicIPs := []string{}
	for _, attr := range taskAttr {

		publicIp := c.GetEniValue(attr.eniId)
		publicIPs = append(publicIPs, publicIp)
	}

	return publicIPs, nil
}

func (c ZentAWSConfig) getTaskAttr(cluster string, taskArns []string) ([]ecsTaskAttrParams, error) {

	output, err := c.ecsClient.DescribeTasks(context.Background(), &ecs.DescribeTasksInput{
		Cluster: aws.String(cluster),
		Tasks:   taskArns,
	})

	if err != nil {
		return nil, err
	}

	var ecsAttrParams []ecsTaskAttrParams
	for _, task := range output.Tasks {

		for _, attach := range task.Attachments {
			_ecsAttr := ecsTaskAttrParams{}

			if attach.Type != nil && *attach.Type == "ElasticNetworkInterface" {
				for _, detail := range attach.Details {
					if detail.Name != nil && *detail.Name == "networkInterfaceId" {
						_ecsAttr.eniId = *detail.Value
					}
				}
			}

			ecsAttrParams = append(ecsAttrParams, _ecsAttr)
		}
	}

	return ecsAttrParams, nil

}

func (c ZentAWSConfig) getECSTaskArns(cluster string, service string) ([]string, error) {

	listTaskOutput, err := c.ecsClient.ListTasks(context.Background(), &ecs.ListTasksInput{
		Cluster:       aws.String(cluster),
		ServiceName:   aws.String(service),
		LaunchType:    "FARGATE",
		DesiredStatus: "RUNNING",
	})

	if err != nil {
		return nil, err
	}

	if len(listTaskOutput.TaskArns) == 0 {
		return nil, err
	}

	return listTaskOutput.TaskArns, nil

}
