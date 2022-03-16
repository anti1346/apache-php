pipeline {
    environment {
        registry = "anti1346/apache-php"
        registryCredential = 'dockerimagepush'
        dockerImage = 'apache-php'
    }

    agent any

    stages {

        stage('Build image') {
            steps {
                sh 'docker build -t $registry:$BUILD_NUMBER .'
                sh 'docker image tag $registry:$BUILD_NUMBER $registry:latest'
                echo 'Build image...'
            }
        }

        stage('Docker run') {
            steps {
                sh 'docker rm -f $(docker ps -q --filter="name=apache-php") || true'
                sh 'docker rmi $(docker images -f "dangling=true" -q) || true'
                sh 'docker run -d -p 8888:80 --name apache-php $registry:$BUILD_NUMBER'
                echo 'Test image...'
            }
        }

        stage("Docker test") {
            steps {
                script {
                    final String url = "localhost:8080"
                    final String response = sh(script: "curl -s $url", returnStdout: true).trim()
                    echo response
                    // final def (String response, int code) = sh(script: "curl -s -w '\\n%{response_code}' $url", returnStdout: true).trim().tokenize("\n")
                    // echo "HTTP response status code: $code"
                    // if (code == 200) {
                    //     echo response
                    // }
                }
            }
        }

        stage('Push image') {
            steps {
                withDockerRegistry([ credentialsId: registryCredential, url: "" ]) {
                    sh 'docker push $registry:$BUILD_NUMBER'
                    sh 'docker push $registry:latest'
                }
                echo 'Push image...'
            }
        }

        stage('Clean image') {
            steps {
                sh 'docker rm -f `docker ps -aq --filter="name=apache-php"`'
                // sh 'docker rmi -f `docker images --filter=reference="$registry"`'
                sh 'docker rmi $registry:$BUILD_NUMBER'
                sh 'docker rmi $registry:latest'
                echo 'Clean image...'
            }
        }

    }
}
