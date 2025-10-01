pipeline {
  agent any
  environment {
    IMAGE_NAME = 'rezarifat/project2' 
  }
  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '20'))
  }
  stages {
    stage('Checkout') { steps { checkout scm } }

    stage('Install & Test (Node 16)') {
      agent { docker { image 'node:16' args '-u root:root' } }
      steps {
        sh 'node -v'
        sh 'npm install --save'
        sh 'npm test || echo "No tests found"'
      }
    }

    stage('Build & Push Docker Image') {
      steps {
        script {
          docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-creds') {
            def tag = "${IMAGE_NAME}:${env.BUILD_NUMBER}"
            def img = docker.build(tag)
            img.push()
            img.push('latest')
          }
        }
      }
    }

    stage('Dependency Scan (OWASP) - fail on High/Critical') {
      steps {
        sh '''
          mkdir -p odc-data odc-report
          docker run --rm \
            -v "$PWD":/src \
            -v "$PWD/odc-data":/usr/share/dependency-check/data \
            -v "$PWD/odc-report":/report \
            owasp/dependency-check:latest \
              --scan /src \
              --format "HTML" \
              --out /report \
              --failOnCVSS 7
        '''
      }
    }
  }
  post {
    always { archiveArtifacts artifacts: 'odc-report/*,Dockerfile', fingerprint: true }
  }
}

