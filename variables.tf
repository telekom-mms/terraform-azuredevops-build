variable "build_definition" {
  type        = any
  default     = {}
  description = "Resource definition, default settings are defined within locals and merged with var settings. For more information look at [Outputs](#Outputs)."
}

locals {
  default = {
    // resource definition
    build_definition = {
      name            = ""
      path            = null
      agent_pool_name = null
      variable_groups = null
      repository = {
        branch_name           = "refs/heads/main" // defined default
        service_connection_id = null
        github_enterprise_url = null
        report_build_status   = null
      }
      ci_trigger = {
        use_yaml = null
        override = {
          batch            = null
          polling_interval = null
          polling_job_id   = null
          branch_filter = {
            include = null
            exclude = null
          }
          path_filter = {
            include = null
            exclude = null
          }
        }
      }
      pull_request_trigger = {
        use_yaml       = null
        initial_branch = null
        override = {
          auto_cancel = null
          branch_filter = {
            include = null
            exclude = null
          }
          path_filter = {
            include = null
            exclude = null
          }
        }
        forks = {}
      }
      variable = {
        name           = ""
        value          = null
        secret_value   = null
        is_secret      = null
        allow_override = null
      }
    }
  }

  // compare and merge custom and default values
  build_definition_values = {
    for build_definition in keys(var.build_definition) :
    build_definition => merge(local.default.build_definition, var.build_definition[build_definition])
  }

  // deep merge of all custom and default values
  build_definition = {
    for build_definition in keys(var.build_definition) :
    build_definition => merge(
      local.build_definition_values[build_definition],
      {
        for config in ["repository"] :
        config => merge(local.default.build_definition[config], local.build_definition_values[build_definition][config])
      },
      {
        for config in ["ci_trigger", "pull_request_trigger"] :
        config => lookup(var.build_definition[build_definition], config, {}) == {} ? null : merge(
          merge(local.default.build_definition[config], local.build_definition_values[build_definition][config]),
          {
            for subconfig in ["override"] :
            subconfig => lookup(local.build_definition_values[build_definition][config], subconfig, {}) == {} ? null : merge(
              merge(local.default.build_definition[config][subconfig], local.build_definition_values[build_definition][config][subconfig]),
              {
                for subsubconfig in ["branch_filter", "path_filter"] :
                subsubconfig => merge(local.default.build_definition[config][subconfig][subsubconfig], lookup(local.build_definition_values[build_definition][config][subconfig], subsubconfig, {}))
              }
            )
          }
        )
      },
      {
        for config in ["variable"] :
        config => keys(local.build_definition_values[build_definition][config]) == keys(local.default.build_definition[config]) ? {} : {
          for key in keys(local.build_definition_values[build_definition][config]) :
          key => merge(local.default.build_definition[config], local.build_definition_values[build_definition][config][key])
        }
      }
    )
  }
}
