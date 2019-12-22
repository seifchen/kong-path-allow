local typedefs = require "kong.db.schema.typedefs"


return {
  name = "kong-path-whitelist",
  fields = {
    { consumer = typedefs.no_consumer },
    { run_on = typedefs.run_on_first },
    { protocols = typedefs.protocols_http },
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