local json = require("cjson")
local kongPathWhitelist = {}

kongPathWhitelist.PRIORITY = 2400
local kong = kong
local ngx = ngx

local function match(source,target, regex)
    if regex and ngx.re.match(source, target) then
        return true
    end
    if not regex and source == target then
        return true
    end
    return false
end

local function get_path()
    local path = kong.request.get_path()
    local route = ngx.ctx.route
    if false == route.strip_path then
        return path
    end

    local result, flag
    for _, prefix in ipairs(route.paths) do
        result, flag = ngx.re.gsub(path, prefix, '/','ajo')
        if flag == 1 then
            return result
        end
    end
    return ""
end

function kongPathWhitelist:access(config)
    local white_paths = config.white_paths
    local regex = config.regex

    local target_path = get_path()
    for _, path in ipairs(white_paths) do
        if match(target_path, path, regex) then
            return
        end
    end
    kong.response.exit(403, json.encode({code = 403, message = "path not allowed"}), {
        ["Content-Type"] = "application/json"})
end

return kongPathWhitelist
