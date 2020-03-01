local typedefs = require "kong.db.schema.typedefs"


return {
  name = "kong-path-whitelist",
  fields = {
    { config = {
        type = "record",
        fields = {
          { white_paths = {
              type = "array",
              required = true,
              elements = typedefs.path
          }
        },
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