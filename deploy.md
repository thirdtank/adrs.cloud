# Deploying Brut Apps

Brut includes support for Docker-based deployment.

This is currently designed to work with Heroku and works as follows:

1 - Dockerfiles per process are created from a base Dockerfile
    - one for web
    - one for 'release' phase
2 - These Dockerfiles are used to create images
3 - These images are pushed to Heroku's container registry
4 - A release is done

