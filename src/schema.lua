local typedefs = require "kong.db.schema.typedefs"


return {
  name = "kong-path-allow",
  fields = {
    { config = {
        type = "record",
        fields = {
          { allow_paths = typedefs.router_paths},
          { deny_paths = typedefs.router_paths},
          { regex = {
              type = "boolean",
              required = true,
              default = true
          }
        }
        }
    } }
  }
}
