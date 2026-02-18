pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID  = '533267129063'
        AWS_REGION      = 'us-east-1'
        ECR_REPO        = 'heroku-repo'
        IMAGE_TAG       = "${BUILD_NUMBER}"
        IMAGE_URI       = "533267129063.dkr.ecr.us-east-1.amazonaws.com/heroku-repo"
        ECS_CLUSTER     = 'heroku-cluster'
        ECS_SERVICE     = 'sample-heroku-task-service'
        TASK_DEFINITION = 'sample-heroku-task'
        CONTAINER_NAME  = 'sample-heroku-container'
    }

    stages {

        stage('Clone Repo') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Anil7749/sampleheroku.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                echo "Building Docker image..."
                docker build -t $ECR_REPO:$IMAGE_TAG .
                '''
            }
        }

        stage('Login to ECR') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials'
                ]]) {
                    sh '''
                    aws ecr get-login-password --region $AWS_REGION | \
                    docker login --username AWS --password-stdin \
                    $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
                    '''
                }
            }
        }

        stage('Tag & Push Image to ECR') {
            steps {
                sh '''
                echo "Tagging image..."
                docker tag $ECR_REPO:$IMAGE_TAG $IMAGE_URI
                echo "Pushing image to ECR..."
                docker push $IMAGE_URI
                '''
            }
        }

        stage('Deploy to ECS') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials'
                ]]) {
                    sh '''
                    echo "Deploying to ECS Fargate..."
                    aws ecs update-service \
                        --cluster $ECS_CLUSTER \
                        --service $ECS_SERVICE \
                        --force-new-deployment \
                        --region $AWS_REGION
                    '''
                }
            }
        }
    }
}
