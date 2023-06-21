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
                        credentialsId: 's3-dev',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]
                ]) {
                    sh 'aws s3 cp ferari_website.tar.gz s3://s3-yotam'
                    sh 'exit'
                }
            }
        }

        stage('Test in ec2-test') {
            steps {
                script {
                    withCredentials([
                        sshUserPrivateKey(credentialsId: 'ec2-test', keyFileVariable: 'SSH_KEY', passphraseVariable: '', usernameVariable: 'SSH_USER')
                    ]) {
                        sh 'echo "Deploying..."'
                        sh 'scp -i $SSH_KEY -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ferari_website.tar.gz $SSH_USER@54.159.62.61:/home/ec2-user/'
                        sh 'ssh -i $SSH_KEY -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $SSH_USER@54.159.62.61 "tar -xzf ferari_website.tar.gz && cd ferari_website/web_project && sudo bash flaskrun.sh && sudo bash /home/ec2-user/ferari_website/web_project/test.sh && sudo bash /home/ec2-user/ferari_website/web_project/flask_stop.sh"'
                        sh 'echo "tasting.."'
                        sh 'exit'
                    }
                }
            }
        }

        stage('Upload to ec2-prod') {
            steps {
                script {
                    withCredentials([
                        sshUserPrivateKey(credentialsId: 'ec2-prod', keyFileVariable: 'SSH_KEY', passphraseVariable: '', usernameVariable: 'SSH_USER')
                    ]) {
                        sh """
                        echo "upload..."
                        scp -i $SSH_KEY -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ferari_website.tar.gz $SSH_USER@34.238.124.145:/home/ec2-user/
                        ssh -i $SSH_KEY -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $SSH_USER@34.238.124.145 "sudo tar -xzf ferari_website.tar.gz"
                        sudo yum install python3-pip -y && sudo pip3 install ansible && sudo yum install git
                        cd /home/ec2-user && git clone https://github.com/yotamdavid/ansible.git
                        cd /ansible/ansible && sudo systemctl daemon-reload && sudo systemctl start && sudo ansible-playbook -i inventory.ini my_playbook.yml
                        """

                    }
                }
            }
        }
    }
}
