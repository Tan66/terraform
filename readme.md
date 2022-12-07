1. command to preview the changes that terraform plans to make to your infrastructure
    ```
    terraform plan
    ```
2. command to apply changes in the plan
    ```
    terraform apply
    ```
3. command to destroy the infrastructure created using terraform apply
    ```
    terraform destroy
    ```

4. enable logging
    ```
    export TF_LOG="TRACE"
    export TF_LOG_PATH="debug.log"
    ```