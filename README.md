# kong-path-whitelist
Determine if the path is in the path whitelist, if not, return 403
# Supporte kong version
Kong >= 1.2
# Install
### Luarocks
```
luarocks install kong-path-whitelist
```

### Source Code
```
$ git clone https://github.com/seifchen/kong-path-whitelist.git
$ cd /path/to/kong/plugins/kong-path-whitelist
$ luarocks make *.rockspec
```

# Usage
## schema
* white_paths: The request path not match this path will forbidden with 403 code
* regex: boolean, if true will use ngx.re.match to match the request_path and white_paths, if false, Will strictly judge whether the two path are equal

## Example
* create service
```
  curl -X POST \
  http://localhost:8001/services \
  -H 'Content-Type: application/json' \
  -d '{
	"name":"kong-path-whitelist-test",
	"protocol":"http",
	"host":"localhost",
	"port":8001}
```
* create route
```
  curl -X POST \
  http://localhost:8001/services/kong-path-whitelist-test/routes \
  -H 'Content-Type: application/json' \
  -d '{
	"name":"kong-path-whitelist-test",
	"paths":["/services"]}
```
* create kong-path-whitelist for route
```
  curl -X POST \
  http://localhost:8001/routes/$routeId/plugins \
  -H 'Content-Type: application/json' \
  -d '{
	"name":"kong-path-whitelist",
	"config":{
		"white_paths":["/services"],
		"regex":true
	}}
```
* request /test/services will return the services object
* request /test/services2 will got 404 not 403
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


* trun the regex to false
```
curl -X PATCH \
  http://localhost:8001/routes/$routeId/plugins/$pluginId \
  -H 'Content-Type: application/json' \
  -d '{
	"name":"kong-path-whitelist",
	"config":{
		"white_paths":["/services"],
		"regex":false
	}
   }
```

* request /test/services will return the services object
* request /test/services2 will got 403 code
```
{"message":"path not allowed"}
```
