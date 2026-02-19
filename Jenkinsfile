pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID  = ''
        AWS_REGION      = ''
        ECR_REPO        = ''
        IMAGE_TAG       = "${BUILD_NUMBER}"
        IMAGE_URI       = ""
        ECS_CLUSTER     = ''
        ECS_SERVICE     = ''
        TASK_DEFINITION = ''
        CONTAINER_NAME  = ''
    }

    stages {

        stage('Clone Repo') {
            steps {
                git branch: 'main',
                    url: ''
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
