pipeline {
    environment {
        registry = "anti1346/apm"
        registryCredential = 'dockerimagepush'
        dockerImage = ''
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

        stage('Test image') {
            steps {
                sh 'docker run -d -p 80:80 --name apm $registry:$BUILD_NUMBER'
                // sh 'docker exec -it $registry:$BUILD curl -Ssf -I http://localhost/phpinfo.php'
                // sh 'curl --fail http://localhost/phpinfo.php || exit 1'
                // sh 'docker rm -f $registry:$BUILD_NUMBER'
                echo 'Test image...'
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
                sh 'docker rm -f `docker ps -aq --filter="name=apm"`'
                // sh 'docker rmi -f `docker images --filter=reference="$registry"`'
                sh 'docker rmi $registry:$BUILD_NUMBER'
                sh 'docker rmi $registry:latest'
                echo 'Clean image...'
            }
        }

    }
}