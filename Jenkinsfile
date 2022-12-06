@Library('jenkins-library')

String agentLabel             = 'docker-build-agent'
String registry               = 'docker.soramitsu.co.jp'
String dockerRegistryRWUserId = 'bot-sora2-rw'
String imageName              = 'docker.soramitsu.co.jp/sora2/polkadot-fearless:latest'

pipeline {
    options {
        buildDiscarder(logRotator(numToKeepStr: '20'))
        timestamps()
        disableConcurrentBuilds()
    }

    agent {
        label agentLabel
    }

    stages {
        stage('Build image') {
            steps{
                script {
                    sh "docker build -f scripts/ci/dockerfiles/polkadot/polkadot_builder.Dockerfile -t ${imageName} ."
                }
            }
        }
        stage('Push Image') {
            steps{
                script {
                    docker.withRegistry( 'https://' + registry, dockerRegistryRWUserId) {
                        sh """
                            docker push ${imageName}
                        """
                    }
                }
            }
        }
    }
    post {
        cleanup { cleanWs() }
    }
}
