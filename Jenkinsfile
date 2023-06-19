pipeline {
    agent any
    
    triggers {
        pollSCM('*/1 * * * *')
    }

    stages {
        stage('Cleanup') {
            steps {
                // Perform the cleanup step here
                sh 'echo "Performing cleanup..."'
                sh 'rm -rf *'
            }
        }

        stage('Clone') {
            steps {
                // Perform the clone step here
                sh 'echo "Building..."'
                sh 'git clone https://github.com/yotamdavid/ferari_website.git'
                sh 'ls'
            }
        }

        stage('Build') {
            steps {
                // Perform the build step here
                sh 'echo "Building..."'
                sh 'echo "packaging"'
                sh 'tar -czvf ferari_website.tar.gz ferari_website'
                sh 'ls'
            }
        }

        stage("Upload to S3") {
            steps {
                withCredentials([
                    [
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'f8c160a5c6dd7b4f8778d716eb900d62f1180caa847144758b3608e544211ede',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]
                ]) {
                    sh 'aws s3 cp ferari_website.tar.gz s3://jenkins-yotam'
                }
            }
        }

        stage('Test in ec2-test') {
            steps {
                sh 'echo "Deploying..."'
                sh 'sudo scp -i /home/yotam/Desktop/yotam.pem -o StrictHostKeyChecking=no ferari_website.tar.gz ec2-user@54.211.131.254:/home/ec2-user/'
                sh 'ssh -i /home/yotam/Desktop/yotam.pem ec2-user@54.211.131.254 "sudo tar -xzf ferari_website.tar.gz && cd ferari_website/web_project && sudo bash flaskrun.sh && sudo bash /home/ec2-user/ferari_website/web_project/test.sh"'
                sh 'echo "tasting.."'
            }
        }

        stage('upload to ec2-prod') {
            steps {
                sh 'echo "upload..."'
                sh 'sudo scp -i /home/yotam/Desktop/yotam.pem -o StrictHostKeyChecking=no ferari_website.tar.gz ec2-user@54.211.131.254:/home/ec2-user/'
                sh 'ssh -i /home/yotam/Desktop/yotam.pem ec2-user@54.211.131.254 "sudo tar -xzf ferari_website.tar.gz && git clone https://github.com/yotamdavid/ansible.git && cd /ansible/ansible/ && ansible-playbook -i inventory.ini my_playbook.yml"'
            }
        }
    }
}
