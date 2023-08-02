/**
* # build
*
* This module manages the microsoft/azuredevops build resources, see https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs.
*
* For more information about the module structure see https://telekom-mms.github.io/terraform-template.
*
*/

resource "azuredevops_build_definition" "build_definition" {
  for_each = var.build_definition

  name            = local.build_definition[each.key].name == "" ? each.key : local.build_definition[each.key].name
  project_id      = local.build_definition[each.key].project_id
  path            = local.build_definition[each.key].path
  agent_pool_name = local.build_definition[each.key].agent_pool_name
  variable_groups = local.build_definition[each.key].variable_groups

  repository {
    branch_name           = local.build_definition[each.key].repository.branch_name
    repo_id               = local.build_definition[each.key].repository.repo_id
    repo_type             = local.build_definition[each.key].repository.repo_type
    service_connection_id = local.build_definition[each.key].repository.service_connection_id
    yml_path              = local.build_definition[each.key].repository.yml_path
    github_enterprise_url = local.build_definition[each.key].repository.github_enterprise_url
    report_build_status   = local.build_definition[each.key].repository.report_build_status
  }

  dynamic "ci_trigger" {
    for_each = local.build_definition[each.key].ci_trigger == {} ? [] : [0]

    content {
      use_yaml = local.build_definition[each.key].ci_trigger.use_yaml

      dynamic "override" {
        for_each = local.build_definition[each.key].ci_trigger.override == null ? [] : [0]

        content {
          batch            = local.build_definition[each.key].ci_trigger.override.batch
          polling_interval = local.build_definition[each.key].ci_trigger.override.polling_interval
          polling_job_id   = local.build_definition[each.key].ci_trigger.override.polling_job_id

          dynamic "branch_filter" {
            for_each = length(compact(flatten(values(local.build_definition[each.key].ci_trigger.override.branch_filter)))) > 0 ? [0] : []

            content {
              include = local.build_definition[each.key].ci_trigger.override.branch_filter.include
              exclude = local.build_definition[each.key].ci_trigger.override.branch_filter.exclude
            }
          }

          dynamic "path_filter" {
            for_each = length(compact(flatten(values(local.build_definition[each.key].ci_trigger.override.path_filter)))) > 0 ? [0] : []

            content {
              include = local.build_definition[each.key].ci_trigger.override.path_filter.include
              exclude = local.build_definition[each.key].ci_trigger.override.path_filter.exclude
            }
          }
        }
      }
    }
  }

  dynamic "pull_request_trigger" {
    for_each = local.build_definition[each.key].pull_request_trigger == null ? [] : [0]

    content {
      use_yaml       = local.build_definition[each.key].pull_request_trigger.use_yaml
      initial_branch = local.build_definition[each.key].pull_request_trigger.initial_branch

      forks {
        enabled       = local.build_definition[each.key].pull_request_trigger.forks.enabled
        share_secrets = local.build_definition[each.key].pull_request_trigger.forks.share_secrets
      }

      dynamic "override" {
        for_each = local.build_definition[each.key].pull_request_trigger.override == null ? [] : [0]

        content {
          auto_cancel = local.build_definition[each.key].pull_request_trigger.override.auto_cancel

          dynamic "branch_filter" {
            for_each = length(compact(flatten(values(local.build_definition[each.key].pull_request_trigger.override.branch_filter)))) > 0 ? [0] : []

            content {
              include = local.build_definition[each.key].pull_request_trigger.override.branch_filter.include
              exclude = local.build_definition[each.key].pull_request_trigger.override.branch_filter.exclude
            }
          }

          dynamic "path_filter" {
            for_each = length(compact(flatten(values(local.build_definition[each.key].pull_request_trigger.override.path_filter)))) > 0 ? [0] : []

            content {
              include = local.build_definition[each.key].pull_request_trigger.override.path_filter.include
              exclude = local.build_definition[each.key].pull_request_trigger.override.path_filter.exclude
            }
          }
        }
      }
    }
  }

  dynamic "variable" {
    for_each = local.build_definition[each.key].variable

    content {
      name           = local.build_definition[each.key].variable[variable.key].name == "" ? variable.key : local.build_definition[each.key].variable[variable.key].name
      value          = local.build_definition[each.key].variable[variable.key].value
      secret_value   = local.build_definition[each.key].variable[variable.key].secret_value
      is_secret      = local.build_definition[each.key].variable[variable.key].is_secret
      allow_override = local.build_definition[each.key].variable[variable.key].allow_override
    }
  }
}
