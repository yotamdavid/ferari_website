pipeline {
    agent any
    
    triggers {
        pollSCM('*/1 * * * *')
    }

    stages {
        stage('Cleanup') {
            steps {
                sh 'echo "Performing cleanup..."'
                sh 'rm -rf *'
            }
        }

        stage('Clone') {
            steps {
                sh 'echo "Building..."'
                sh 'git clone https://github.com/yotamdavid/ferari_website.git'
                sh 'ls'
            }
        }

        stage('Build') {
            steps {
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
                    sh 'exit'
                }
            }
        }

        stage('Test in ec2-test') {
            steps {
                script {
                    withCredentials([
                        sshUserPrivateKey(credentialsId: '18.206.124.47', keyFileVariable: 'SSH_KEY', passphraseVariable: '', usernameVariable: 'SSH_USER')
                    ]) {
                        sh 'echo "Deploying..."'
                        sh 'scp -i $SSH_KEY -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ferari_website.tar.gz $SSH_USER@34.224.27.13:/home/ec2-user/'
                        sh 'ssh -i $SSH_KEY -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $SSH_USER@34.224.27.13 "tar -xzf ferari_website.tar.gz && cd ferari_website/web_project && sudo bash flaskrun.sh && sudo bash /home/ec2-user/ferari_website/web_project/test.sh"'
                        sh 'echo "tasting.."'
                    }
                }
            }
        }

        stage('Upload to ec2-prod') {
            steps {
                script {
                    withCredentials([
                        sshUserPrivateKey(credentialsId: '34.224.27.13', keyFileVariable: 'SSH_KEY', passphraseVariable: '', usernameVariable: 'SSH_USER')
                    ]) {
                        sh 'echo "upload..."'
                        sh 'sudo scp -i SSH_KEY -o StrictHostKeyChecking=no ferari_website.tar.gz SSH_USER@18.206.124.47:/home/ec2-user/'
                        sh 'ssh -i SSH_KEY -o StrictHostKeyChecking=no SSH_USER@18.206.124.47 "sudo tar -xzf ferari_website.tar.gz && git clone https://github.com/yotamdavid/ansible.git && cd /ansible/ansible/ && ansible-playbook -i inventory.ini my_playbook.yml"'
                    }
                }
            }
        }
    }
}
