# kong-path-allow
Determine if a path is allowed, if not, return 403
# Supporte kong version
Kong >= 1.2
# Install
### Select Version
because this breaking changes with kong version within 2.* and 3.*.
* If you use kong < 3.0 please use 0.1-3 or tag:v0.1.3
* If you use kong >= 3.0 please use 0.2-0 or tag:v0.2.0
### Luarocks
```
luarocks install kong-path-allow $version 
```

### Source Code
```
$ git clone -b $tagName https://github.com/seifchen/kong-path-allow.git
$ cd /path/to/kong/plugins/kong-path-allow
$ luarocks make *.rockspec
```

# Usage
## schema
* allow_paths: if the request path not match this path will forbidden with 403 code
* deny_paths: if the request path match this path will forbidden with 403 code
* regex: boolean, if true will use ngx.re.match to match the request_path and allow_paths/deny_paths, if false, will strictly judge whether the two path are equal

## Example
* create service
```
  curl -X POST \
  http://localhost:8001/services \
  -H 'Content-Type: application/json' \
  -d '{
	"name":"kong-path-allow-test",
	"protocol":"http",
	"host":"localhost",
	"port":8001}'
```
* create route
```
  curl -X POST \
  http://localhost:8001/services/kong-path-allow-test/routes \
  -H 'Content-Type: application/json' \
  -d '{
	"name":"kong-path-allow-test",
	"paths":["/test/"]}'
```
* create kong-path-allow for route
```
  curl -X POST \
  http://localhost:8001/routes/$routeId/plugins \
  -H 'Content-Type: application/json' \
  -d '{
	"name":"kong-path-allow",
	"config":{
		"allow_paths":["/services"],
		"regex":true
	}}'
```
* request /services will return the services object
* request /services2 will got 404 not 403
```
  HTTP/1.1 404 Not Found
  Content-Type: application/json; charset=utf-8
  Content-Length: 23
  Connection: keep-alive
  Date: Sun, 22 Dec 2019 08:04:14 GMT
  Access-Control-Allow-Origin: *
  Server: kong/1.4.0
  X-Kong-Upstream-Latency: 2
  X-Kong-Proxy-Latency: 1
  Via: kong/1.4.0
  * Connection #0 to host localhost left intact
  {"message":"Not found"}
```
* request /test/routes will got 403
```
{"message":"path not allowed"}
```

* create kong-path-deny for route
```
  curl -X POST \
  http://localhost:8001/routes/$routeId/plugins \
  -H 'Content-Type: application/json' \
  -d '{
	"name":"kong-path-allow",
	"config":{
		"deny_paths":["/services/x"],
		"regex":true
	}}'
```
* request /test/services/ will return the services object
* request /test/services/x will now got 403 
```
{"message":"path not allowed"}
```


* turn the regex to false
```
curl -X PATCH \
  http://localhost:8001/routes/$routeId/plugins/$pluginId \
  -H 'Content-Type: application/json' \
  -d '{
	"name":"kong-path-allow",
	"config":{
		"allow_paths":["/services"],
		"regex":false
	}
   }'
```

* request /test/services will return the services object
* request /test/services2 will got 403 code
```
{"message":"path not allowed"}
```
