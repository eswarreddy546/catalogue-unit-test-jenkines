pipeline {

    agent { label 'AGENT-1' }

    environment {
        COURSE = "Jenkins"
        ACC_ID = "160885265516"
        PROJECT = "roboshop"
        COMPONENT = "catalogue"
        APP_VERSION = "latest"
    }

    options {
        timeout(time: 10, unit: 'MINUTES')
        disableConcurrentBuilds()
    }

    stages {

        stage('Read Version') {
            steps {
                script {
                    def packageJSON = readJSON file: 'package.json'
                    env.APP_VERSION = packageJSON.version ?: "latest"
                    echo "App version: ${env.APP_VERSION}"
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                npm install --include=dev
                '''
            }
        }

        stage('Unit Test') {
            steps {
                sh '''
                npm test
                '''
            }
        }

        stage('Sonar Scan') {
            steps {
                script {
                    def scannerHome = tool 'Sonar 8.0'
                    withSonarQubeEnv('sonar-server') {
                        sh "${scannerHome}/bin/sonar-scanner"
                    }
                }
            }
        }

        // stage('Quality Gate') {
        //     steps {
        //         timeout(time: 1, unit: 'HOURS') {
        //             waitForQualityGate abortPipeline: true
        //         }
        //     }
        // }

        stage('Build Docker Image') {
            steps {
                sh '''
                echo "PROJECT=${PROJECT}"
                echo "COMPONENT=${COMPONENT}"
                echo "APP_VERSION=${APP_VERSION}"

                docker build -t ${PROJECT}-${COMPONENT}:${APP_VERSION} .
                '''
            }
        }

        stage('Trivy Image Scan') {
            steps {
                sh '''
                trivy image --severity HIGH,CRITICAL ${PROJECT}-${COMPONENT}:${APP_VERSION}
                '''
            }
        }

    }

    post {

        always {
            echo 'Cleaning workspace'
            cleanWs()
        }

        success {
            echo 'Pipeline completed successfully'
        }

        failure {
            echo 'Pipeline failed'
        }

        aborted {
            echo 'Pipeline aborted'
        }

    }
}