/* Import shared library */
@Library('omar-shared-library')_

pipeline {
     environment {
       ID_DOCKER = "${ID_DOCKER_PARAMS}"
       IMAGE_NAME = "staticwebsite"
       IMAGE_TAG = "latest"
       PORT_EXPOSED = "80" // Vous devez spécifier le port ici
       APP_NAME = "Omar"
       STG_API_ENDPOINT = "http://ip10-0-0-3-cka6snct654gqaevke6g-1993.direct.docker.labs.eazytraining.fr"
       STG_APP_ENDPOINT = "http://ip10-0-0-3-cka6snct654gqaevke6g-80.direct.docker.labs.eazytraining.fr"
       PROD_API_ENDPOINT = "http://ip10-0-0-4-cka6snct654gqaevke6g-1993.direct.docker.labs.eazytraining.fr"
       PROD_APP_ENDPOINT = "http://ip10-0-0-4-cka6snct654gqaevke6g-80.direct.docker.labs.eazytraining.fr"
       INTERNAL_PORT = "5000"
       EXTERNAL_PORT = "${PORT_EXPOSED}"
       CONTAINER_IMAGE = "${ID_DOCKER}/${IMAGE_NAME}:${IMAGE_TAG}"
     }
     agent any
     stages {
         stage('Build image') {
             steps {
                script {
                  sh 'docker build -t ${ID_DOCKER}/$IMAGE_NAME:$IMAGE_TAG .'
                }
             }
        }
        stage('Run container based on builded image') {
            steps {
               script {
                 sh '''
                    echo "Clean Environment"
                    docker rm -f $IMAGE_NAME || echo "container does not exist"
                    docker run --name $IMAGE_NAME -d -p ${PORT_EXPOSED}:${INTERNAL_PORT} -e PORT=${INTERNAL_PORT} ${ID_DOCKER}/$IMAGE_NAME:$IMAGE_TAG
                    sleep 5
                 '''
               }
            }
       }
       stage('Test image') {
           steps {
              script {
                sh '''
                    curl http://127.0.0.1:${PORT_EXPOSED} | grep -i "Dimension"
                '''
              }
           }
      }
      stage('Clean Container') {
          steps {
             script {
               sh '''
                 docker stop $IMAGE_NAME
                 docker rm $IMAGE_NAME
               '''
             }
          }
     }

      stage('Save Artefact') {
          steps {
             script {
               sh '''
                 docker save  ${ID_DOCKER}/$IMAGE_NAME:$IMAGE_TAG > /tmp/alpinehelloworld.tar                 
               '''
             }
          }
     }          
          
     stage ('Login and Push Image on docker hub') {
        environment {
           DOCKERHUB_PASSWORD  = credentials('dockerhub-credentials')
        }            
          steps {
             script {
               sh '''
                   echo $DOCKERHUB_PASSWORD_PSW | docker login -u $ID_DOCKER --password-stdin
                   docker push ${ID_DOCKER}/$IMAGE_NAME:$IMAGE_TAG
               '''
             }
          }
      }    
     
     stage('STAGING - Deploy app') {
      steps {
          script {
            sh """
              echo  {\\"your_name\\":\\"${APP_NAME}\\",\\"container_image\\":\\"${CONTAINER_IMAGE}\\", \\"external_port\\":\\"${EXTERNAL_PORT}\\", \\"internal_port\\":\\"${INTERNAL_PORT}\\"}  > data.json 
              curl -X POST ${STG_API_ENDPOINT}/staging -H 'Content-Type: application/json'  --data-binary @data.json 
            """
          }
        }
     }

     stage('PRODUCTION - Deploy app') {
       when {
          expression { GIT_BRANCH == 'origin/master' }
       }
       steps {
          script {
            sh """
               curl -X POST ${PROD_API_ENDPOINT}/prod -H 'Content-Type: application/json' -d '{"your_name":"${APP_NAME}","container_image":"${CONTAINER_IMAGE}", "external_port":"${EXTERNAL_PORT}", "internal_port":"${INTERNAL_PORT}"}'
               """
          }
        }
     }
  }
  post {
       always {
      script {
           slackNotifier currentBuild.result
      }
     }       
    }     
}

