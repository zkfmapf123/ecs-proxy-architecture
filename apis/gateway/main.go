package main

import (
	"fmt"
	"log"
	"os"

	"github.com/gofiber/fiber/v2"
	"github.com/zenterprize/hometax-gateway/aws"
)

var (
	PORT        = os.Getenv("PORT")
	ECS_CLUSTER = os.Getenv("ECS_CLUSTER")
	ECS_SERVICE = os.Getenv("ECS_SERVICE")
)

func main() {

	awsConfig := aws.NewAWS()

	app := fiber.New(
		fiber.Config{
			Prefork:       true,
			CaseSensitive: true,
			StrictRouting: true,
			AppName:       fmt.Sprintf("gateway : %s", PORT),
		},
	)

	app.Get("/ping", func(c *fiber.Ctx) error {
		return c.SendStatus(200)
	})

	app.Get("/ip", func(c *fiber.Ctx) error {
		ips, err := awsConfig.GetContainerPublicIP(ECS_CLUSTER, ECS_SERVICE)
		if err != nil {
			log.Fatalln(err)

			return c.JSONP(map[string]interface{}{
				"result": []string{},
				"error":  err,
			})
		}

		hometaxPublicIp := []string{}
		for _, ip := range ips {
			hometaxPublicIp = append(hometaxPublicIp, fmt.Sprintf("http://%s:3182", ip))
		}

		log.Println(hometaxPublicIp, err)

		return c.JSONP(map[string]interface{}{
			"result": hometaxPublicIp,
			"error":  err,
		})
	})

	log.Fatalln(app.Listen(fmt.Sprintf(":%s", PORT)))
}
