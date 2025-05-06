# Variables
COMPOSE_FILE = docker-compose.yml
JENKINS_CONTAINER = jenkins  # Replace with your Jenkins container name
NEXUS_CONTAINER = nexus     # Replace with your Nexus container name

# Default target
all: up get-jenkins-password get-sonar-password get-nexus-password status

# Start the containers
up:
	docker-compose -f $(COMPOSE_FILE) up -d

# Get Jenkins admin password
get-jenkins-password:
	@echo "Getting Jenkins Initial Admin Password:"
	@sleep 50
	@docker exec $(JENKINS_CONTAINER) cat /var/jenkins_home/secrets/initialAdminPassword
	@echo ""

get-sonar-password:
	@echo "Getting Sonarqube Initial Password"
	@echo "Username: Admin , Password: Admin"
	@echo ""
# Get Nexus admin password
get-nexus-password:
	@echo "Getting Nexus Initial Admin Password, Allow container to fully initialize."
	@sleep 150
	@docker exec $(NEXUS_CONTAINER) cat /nexus-data/admin.password
	@echo ""

status:
	@echo "checking the status of Deployed containers"
	docker-compose ps

# Stop and remove containers
down:
	docker-compose -f $(COMPOSE_FILE) down

# Clean up
clean: down

# Phony targets
.PHONY: all up get-jenkins-password get-nexus-password down clean
