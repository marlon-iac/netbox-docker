alguns comandos:

git clone https://github.com/netbox-community/netbox-docker.git
cd netbox-docker
git checkout v4.0.2

cd netbox-docker/
docker compose up -d: Inicia os contêineres em segundo plano.
docker compose up: Inicia os containeres com logs
docker compose ps: Lista os contêineres em execução.
docker compose logs -f: Exibe os logs dos contêineres em tempo real.
docker compose logs -f netbox

docker images:

docker compose down:

# acessa o container do netbox como root
docker compose exec -u root netbox bash


### começar imagem do zero
docker compose down -v (apaga todos os dados persistidos)
docker volume prune -f
docker compose pull
docker compose up -d

Referencias:

- https://github.com/netbox-community/netbox-docker/wiki/
- https://deepwiki.com/netbox-community/netbox-docker
- https://github.com/netbox-community/netbox-docker
- https://github.com/netbox-community/netbox-docker/wiki/Deployment