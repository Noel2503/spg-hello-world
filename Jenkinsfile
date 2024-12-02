pipeline {
    environment {
        registry = "noel135/img-repo"
        registryCredential = 'docker-credential'
        dockerImage = ''
        docker_version = "${BUILD_NUMBER}"
        deployment_file = "${WORKSPACE}/deployment.yaml"
        service_file = "${WORKSPACE}/service.yaml"
        KUBECONFIG_CREDENTIAL_ID = 'kubeconfig'
    }
    agent any
    stages {
        stage('Cloning our Git') {
            steps {
                git(
                    url: 'https://github.com/Noel2503/spg-hello-world.git',
                    credentialsId: 'git-credential',
                    branch: 'master'
                )
            }
        }
        stage('Build with Maven') {
            steps {
                script {
                    sh "mvn clean package -Dpackaging=war -DskipTests -DargLine="-Xmx1024m -XX:MaxPermSize=256m"" // Build a WAR file
                }
            }
        }
        stage('Building Docker Image with WAR') {
            steps {
                script {
                    // Build the Docker image based on Tomcat and include the WAR
                    dockerImage = docker.build registry + ":$docker_version", """
                    --build-arg WAR_FILE=target/*.war \
                    -f Dockerfile .
                    """
                }
            }
        }
        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('', registryCredential) {  
                        dockerImage.push()
                    }
                }
            }
        }
        stage('Pull Docker Image') {
            steps {
                script {
                    sh 'docker pull "$registry":"$docker_version"' 
                }
            }
        }
        stage('Update Image in Deployment File on GitHub') {
            steps {
                script {
                    sh "sed -i 's|image: .*|image: ${registry}:${docker_version}|g' ${deployment_file}"
                }
            }
        }
        stage('Update Deployment File to GitHub') {
            steps {
                withCredentials([string(credentialsId: 'git-spgboot', variable: 'git_token_test')]) {
                    sh '''
                        git config --global user.name "Noel2503"
                        git config --global user.email "noelyesuraj25@gmail.com"
                        git add ${deployment_file}
                        git commit -m "Updated deployment docker file"
                        git push https://$git_token_test@github.com/Noel2503/spg-hello-world.git HEAD:master
                    '''
                }
            }
        }
        stage('Apply Kubernetes YAML') {
            steps {
                script {
                    if (fileExists("${deployment_file}")) {
                        echo "Deployment file found. Deleting and applying file"

                        withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                            sh "kubectl delete -f ${deployment_file} -n tomcat-new --ignore-not-found"
                            sh "kubectl apply -f ${deployment_file} -n tomcat-new"
                        }
                    } else {
                        error "Deployment file not found. Applying."
                        sh "kubectl apply -f ${deployment_file} -n tomcat-new"
                    }
                }
            }
        }
        stage('Cleaning up') {
            steps {
                script {
                    sh 'docker rmi $registry:$BUILD_NUMBER'
                }
            }
        }
    }
}
