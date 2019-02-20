#!/usr/bin/env bash

# more bash-friendly output for jq
JQ="jq --raw-output --exit-status"

configure_aws_cli(){
	aws --version
	aws configure set default.region eu-west-1 # change this if your AWS region differs
	aws configure set default.output json
}

deploy_cluster() {

    family="film_ratings_app"

    make_task_def
    register_definition
    if [[ $(aws ecs update-service --cluster film_ratings_cluster  --service film_ratings_app_service --task-definition $revision | \
                   $JQ '.service.taskDefinition') != $revision ]]; then
        echo "Error updating service."
        return 1
    fi

    # wait for older revisions to disappear
    # not really necessary, but nice for demos
    for attempt in {1..15}; do
        if stale=$(aws ecs describe-services --cluster film_ratings_cluster --services film_ratings_app_service | \
                       $JQ ".services[0].deployments | .[] | select(.taskDefinition != \"$revision\") | .taskDefinition"); then
            echo "Waiting for stale deployments:"
            echo "$stale"
            sleep 20
        else
            echo "Deployed!"
            return 0
        fi
    done
    echo "Service update took too long."
    return 1
}

make_task_def(){
	task_template='[
                {
                    "name": "film_ratings_app",
                    "image": "%s:%s",
                    "essential": true,
                    "portMappings": [
                      {
                          "containerPort": 3000,
                          "hostPort": 3000
                      }
                    ],
                    "environment": [
                      {
                        "name": "DB_HOST",
                        "value": "%s"
                      },
                      {
                        "name": "DB_PASSWORD",
                        "value": "%s"
                      }
                    ],
                    "logConfiguration": {
                      "logDriver": "awslogs",
                      "options": {
                        "awslogs-group": "film_ratings_app",
                        "awslogs-region": "eu-west-1",
                        "awslogs-stream-prefix": "ecs"
                      }
                    },
                    "memory": 1024,
                    "cpu": 256
                }
	]'

	task_def=$(printf "$task_template" $IMAGE_NAME $CIRCLE_TAG $DB_HOST $DB_PASSWORD)
}

register_definition() {

    if revision=$(aws ecs register-task-definition --container-definitions "$task_def" --family $family | $JQ '.taskDefinition.taskDefinitionArn'); then
        echo "Revision: $revision"
    else
        echo "Failed to register task definition"
        return 1
    fi

}

configure_aws_cli
deploy_cluster
