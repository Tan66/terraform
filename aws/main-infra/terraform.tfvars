ecr_config = {
    ecr1 = {
        repository_name = "demo",
        image_tag_mutability = "MUTABLE"
        force_delete = true
        scan_on_push = false
        tags = {
            team = "devops"
        }
    }
}