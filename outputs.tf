output "build_definition" {
  description = "Outputs all attributes of resource_type."
  value = {
    for build_definition in keys(azuredevops_build_definition.build_definition) :
    build_definition => {
      for key, value in azuredevops_build_definition.build_definition[build_definition] :
      key => value
    }
  }
}

output "variables" {
  description = "Displays all configurable variables passed by the module. __default__ = predefined values per module. __merged__ = result of merging the default values and custom values passed to the module"
  value = {
    default = {
      for variable in keys(local.default) :
      variable => local.default[variable]
    }
    merged = {
      build_definition = {
        for key in keys(var.build_definition) :
        key => local.build_definition[key]
      }
    }
    var = var.build_definition
  }
}
