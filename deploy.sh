#!/bin/bash

# To run the deployment:
# Initialise the remote state first with ./deploy.sh
# ./deploy.sh [plan|apply|destroy]

# capture the current path
current_path=$(pwd)
tf_command=$1


function initialize_state {
        echo 'Initializing remote terraform state'
        cd tfstate
        terraform init
        terraform apply -auto-approve
        cd "${current_path}"
}

function deploy_blueprint {
        cd tfstate
        storage_account_name=$(terraform output storage_account_name)
        echo ${storage_account_name}
        access_key=$(terraform output access_key)
        container=$(terraform output container)
        prefix=$(terraform output prefix)
        tf_name="${prefix}.tfstate"

        cd "${current_path}"
        pwd 

        terraform init \
                -reconfigure \
                -backend=true \
                -lock=false \
                -backend-config storage_account_name=${storage_account_name} \
                -backend-config container_name=${container} \
                -backend-config access_key=${access_key} \
                -backend-config key=${tf_name}

        terraform ${tf_command} \
                -var prefix=${prefix}

}


# Initialise storage account to store remote terraform state
if [[ -z "$2" ]]; then
        initialize_state
fi

if [[ -n "${tf_command}" ]]; then
        echo ''
        echo "Deploying blueprint with terraform command '${tf_command}'"
        echo ''
        deploy_blueprint
else
        echo ''
        echo 'You have to run at least once ./deploy.sh with no parameters to setup the remote state.'
        echo 'To deploy a bluepring run the terraform command [plan|apply|destroy]'
        echo './deploy.sh plan'
        echo ''
        echo 'Note: the script does the terraform init for you.'
fi