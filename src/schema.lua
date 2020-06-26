local typedefs = require "kong.db.schema.typedefs"


return {
  name = "kong-path-allow",
  fields = {
    { config = {
        type = "record",
        fields = {
          { allow_paths = {
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