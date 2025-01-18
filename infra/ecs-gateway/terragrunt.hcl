include "root" {
    path = find_in_parent_folders("__shared__.hcl")
}

inputs = {
    config = dependency.config.outputs
}