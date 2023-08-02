module "core" {
  source = "registry.terraform.io/telekom-mms/core/azuredevops"
  project = {
    mms = {}
  }
}

module "build" {
  source = "registry.terraform.io/telekom-mms/build/azuredevops"
  build_definition = {
    dmc = {
      project_id = module.core.project["mms"].id
      repository = {
        repo_id   = "telekom-mms/docker-management-container"
        repo_type = "GitHub"
        yml_path  = "examples/pipeline/azure-devops.yml"
      }
    }
  }
}
