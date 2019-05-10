# SONARQUBE
alias docker-sonarqube-start='docker run -d -e "TZ=America/Sao_Paulo" -p 9000:9000 -p 9092:9092 --name sonarqube sonarqube'
alias docker-sonarqube-scanner='docker run -ti -v $(pwd):/root/src --link sonarqube newtmitch/sonar-scanner'

# SWAGGER UI
alias docker-swagger-start='docker run -d -p 8080:8080 swaggerapi/swagger-ui'

# SWITCH PHP VERSION
alias define-php-7.1='sudo update-alternatives --set php /usr/bin/php7.1'
alias define-php-7.2='sudo update-alternatives --set php /usr/bin/php7.2'
