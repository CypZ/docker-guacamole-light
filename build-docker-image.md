
## Step 1: Build docker-guacamole-light Docker image locally

Build the docker-guacamole-light image locally. Make sure to include "." at the end. Make sure the build runs to completion without errors. You should get a success message.
````bash
cd ~/docker-guacamole-light/
docker build -t docker-guacamole-light:v1.4.0 .
````

## Step 2: Test image
````bash
docker run -p 9999:8080 --name docker-guacamole-light --hostname docker-guacamole-light docker-guacamole-light:v1.4.0
````

## Step 3: Test the application locally
Now that we've launched the application containers, let's try to test the web application locally.

[Test](http://<IP-Address>:9999/)

## Step 4: Troubleshoot and inspecting 
````bash
docker inspect docker-guacamole-light
docker inspect docker-guacamole-light --format '{{.Config.Entrypoint}}'
````

## Step 5: Cleanup application containers & empty docker build cache
When we're finished testing, we can terminate and remove the currently running frontend and backend containers from our local machine:
````bash
docker rm -f docker-guacamole-light
docker system prune -a
````

## Step 6 Go to https://hub.docker.com/repository/create and create the corresponding repo

## Step 7: Tag / map image
````bash
docker tag docker-guacamole-light:v1.4.0 cypz/guacamole-light:v1.4.0
````

## Step 8: publish images to the registry
````bash
docker login
docker push cypz/guacamole-light:v1.4.0
````


