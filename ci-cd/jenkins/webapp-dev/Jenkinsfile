pipeline{
    agent { label 'node_aws'}
    tools {
        maven 'maven3.9'
    }
    stages{
        stage('Code checkout'){
            steps{
                echo "checking out code"
                git branch: 'main', url: 'https://github.com/ifediniru/docker_local.git'
            }
        }
        stage('Maven Build'){
            steps{
                echo "Building source code using Maven from Jenkins file"
                sh "mvn clean package"
                // sh "mvn package"
                echo "Building source code using Maven was successful"
            }
        }
        stage('Sonarqube Analysis'){
            steps{
                echo "Analysing Sourcecode"
                // sh "mvn sonar:sonar -Dsonar.qualitygate.wait=true"
            }
        }
        stage('Artifact Management'){
            steps{
                echo "Pushing artifacts to Nexus"
                // sh "mvn deploy -s ./settings.xml"
            }
        }
        stage('Tomcat Deploy'){
            steps{
                echo "Deploying Application to Tomcat"
                // sh "rm -rf '/tmp/demojenkins'"
                deploy adapters: [tomcat9(credentialsId: 'tomcat2', path: '', url: 'https://98df-142-198-195-76.ngrok-free.app')], contextPath: null, war: 'target/*.war'
            }
        }
    }
}
