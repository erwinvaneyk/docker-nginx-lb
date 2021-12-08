# Docker-nginx-lb

Nginx-lb is an extremely simple nginx-based load-balancer packaged in a Docker 
container. It accepts requests at specified port distributes the requests over 
one or more backend servers.

In effect this project is a lightweight wrapper (~23 MB) over the 
[nginx](https://hub.docker.com/_/nginx) Docker image (the `alpine` variant). 
It is compatible with most options available present in those images.

Although in most cases it is better to use the plain `nginx` image, there are a 
couple of use cases where this image to create a load-balancer is useful:

1. When prototyping, where you just want to quickly bring up a basic load-balancer;
2. When working with a Docker environment that does not support volumes to mount a custom `nginx.conf`.

## Usage
To proxy all requests to `example.com`:
```shell
docker run --rm --name example-nginx-lb \
  -p 9090:9090 \
  -e LB_PORT=9090 \
  -e LB_BACKENDS=example.com:80 \
  erwinvaneyk/nginx-lb:latest
```

You can use a simple curl command to see if it works:
```shell
curl -H "Host: example.com" http://localhost:9090
```

## Configuration
On top of the configuration options of the plain `nginx` image, this image adds
the following configuration options:

| Environment Variable | Description                                                   | Default      | Examples      |
|----------------------|---------------------------------------------------------------|--------------|---------------|
| `LB_PORT`            | The port the LB should accept requests on.                    | `80`         | `443`, `9090` |
| `LB_BACKENDS`        | The server(s) to which the LB should distribute the requests, comma-separated. | `example.com:80` | `server1.example.com:3030,server2.example.com:3031` |

## Building

To build the Docker image yourself, you can use the plain Docker build workflow:

```shell
docker build --tag erwinvaneyk/nginx-lb:latest .
```