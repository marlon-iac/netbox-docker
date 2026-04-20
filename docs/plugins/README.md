[ ] documentar esse guia

# Sobre

Esse guia é um procedimento de como eu fiz para criar uma imagem do netbox com plugin instalado

# Passo a passo

1. criei um [plugin_requirements.txt](../netbox-custom/plugin_requirements.txt) e adicionei o plugin que quero instalar na imagem do netbox

2. criei o arquivo [Dockerfile-Plugins](../netbox-custom/Dockerfile-Plugins) do zero, contendo o procedimento de instalação dentro do venv no container do netbox

```docker
FROM netboxcommunity/netbox:v4.5-4.0.2

COPY plugin_requirements.txt /opt/netbox/

RUN /usr/local/bin/uv pip install -r /opt/netbox/plugin_requirements.txt
```

3. configurei o arquivo [configuration.py](../netbox-custom/configuration/configuration.py) adicionando a linha PLUGINS = ['slurpit_netbox'] que é o plugin desejado na instalação para habilitar o plugin no netbox

4. configurei o arquivo [docker-compose.override.yml](../netbox-custom/docker-compose.override.yml) adicionando o build para o arquivo [Dockerfile-Plugins](../netbox-custom/Dockerfile-Plugins)

```docker
services:
  netbox:
    build:                               <----- essa linha
      context: .                         <----- essa linha
      dockerfile: Dockerfile-Plugins     <----- essa linha
    image: netbox:custom                 <----- essa linha
    ports:
      - "8000:8080"
    healthcheck:
      start_period: 500s
      timeout: 30s
      interval: 30s
      retries: 5
  netbox-worker:                         <----- essa linha
    image: netbox:custom                 <----- essa linha
```

5. fiz o build executando os comandos abaixo:

```sh
docker compose down
docker compose build --no-cache
docker compose up -d
```

6. Validei acessando a imagem com o comando

```sh
cd netbox-docker
docker compose exec -u root netbox bash
/opt/netbox/venv/bin/python -m pip list | grep slurpit
```

# Plugins

- https://netboxlabs.com/plugins/
- https://github.com/onemind-services-llc/netbox-metatype-importer
- https://github.com/andy-shady-org/netbox-device-module-type-importer
- https://github.com/netboxlabs/diode-netbox-plugin
- 

# Referencias

- https://netbox.readthedocs.io/en/stable/plugins/
- https://netbox.readthedocs.io/en/stable/plugins/installation/
- https://netboxlabs.com/docs/netbox/plugins/installation/
- https://www.youtube.com/watch?v=DODzEsMTmKQ
- https://redes-abertas.readthedocs.io/en/Guias/Netbox/Plugins/Branching/