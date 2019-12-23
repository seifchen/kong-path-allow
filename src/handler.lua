local json = require("cjson")
local kongPathWhitelist = {}

kongPathWhitelist.PRIORITY = 2400
local kong = kong
local ngx = ngx

local function match(source,target, regex)
    if regex then
        local from = ngx.re.find(source, target)
        if from == 1 then
            return true
        end
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

    local from, to,req_path
    for _, prefix in ipairs(route.paths) do
        from, to = ngx.re.find(path, prefix, "jo")
        if from == 1 then
            req_path = string.sub(path, to+1, #path)
            from = ngx.re.find(req_path, "/", "jo")
            if not from then
                req_path = '/' .. req_path
            end
            return req_path
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
    kong.response.exit(403, json.encode({message = "path not allowed"}), {
        ["Content-Type"] = "application/json"})
end

return kongPathWhitelist
