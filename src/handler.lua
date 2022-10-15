local json = require("cjson")
local kong_meta     = require "kong.meta"
local kongPathAllow = {}

kongPathAllow.PRIORITY = 840
kongPathAllow.VERSION = kong_meta.version
local kong = kong
local ngx = ngx
local re_find = ngx.re.find
local sub = string.sub

local function match(source,target, regex)
    if regex then
        local from = re_find(source, target)
        if from == 1 then
            return true
        end
    end
    if not regex and source == target then
        return true
    end
    return false
end

local function get_target_path()
    local get_path = kong.request.get_path
    local path = get_path()
    local route = ngx.ctx.route
    local strip_path = route.strip_path
    if false == strip_path then
        return path
    end

    local paths = route.paths
    local from, to,req_path
    for _, prefix in ipairs(paths) do
        from, to = re_find(path, prefix, "jo")
        if from == 1 then
            req_path = sub(path, to+1, #path)
            from = re_find(req_path, "/", "jo")
            if not from or from ~=1 then
                req_path = '/' .. req_path
            end
            return req_path
        end
    end
    return ""
end

function kongPathAllow:access(config)
    local allow_paths = config.allow_paths
    local deny_paths = config.deny_paths
    local regex = config.regex

    local target_path = get_target_path()
    -- deny_paths
    if deny_paths then
        for _, path in ipairs(deny_paths) do
            if match(target_path, path, regex) then
                kong.response.exit(403, json.encode({message = "path not allowed"}),
                    { ["Content-Type"] = "application/json"})
                return
            end
        end
    end
    -- deny_paths and not allow_paths => authorize by default
    if deny_paths and not allow_paths then
        return
    end
    -- allow_paths
    if allow_paths then
        for _, path in ipairs(allow_paths) do
            if match(target_path, path, regex) then
                return
            end
        end
    end
    kong.response.exit(403, json.encode({message = "path not allowed"}), {
        ["Content-Type"] = "application/json"})
end

return kongPathAllow
