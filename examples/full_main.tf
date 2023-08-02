data "azuredevops_git_repository" "dmc" {
  project_id = module.core.project["mms"].id
  name       = "dmc"
}

module "core" {
  source = "registry.terraform.io/telekom-mms/core/azuredevops"
  project = {
    mms = {}
  }
}

module "taskagent" {
  source = "registry.terraform.io/telekom-mms/taskagent/azuredevops"
  variable_group = {
    dmc = {
      project_id = module.core.project["mms"].id
      variable = {
        name = {
          value = "mms-mgmt-dmc"
        }
      }
    }
  }
}

module "build" {
  source = "registry.terraform.io/telekom-mms/build/azuredevops"
  build_definition = {
    dmc = {
      project_id = module.core.project["mms"].id
      variable_groups = [
        module.taskagent.variable_group["dmc"].id
      ]
      repository = {
        repo_id   = data.azuredevops_git_repository.dmc.id
        repo_type = "TfsGit"
        yml_path  = "examples/pipeline/azure-devops.yml"
      }
      ci_trigger = {
        override = {
          branch_filter = {
            include = ["main"]
          }
        }
      }
      variable = {
        version = {
          value = "latest"
        }
      }
    }
  }
}
