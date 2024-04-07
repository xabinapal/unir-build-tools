# Repo para EIEC - DevOps - UNIR

Este repositorio incluye comandos para facilitar el arranque de un servidor de Jenkins.

Los comandos del Makefile funcionarán en Linux y MacOS. En caso de usar Windows,
necesitarás adaptarlos o ejecutarlos en una máquina virtual Linux.

## Guía rápida

1. Ejecuta `make build-agents` para construir las imágenes de los agentes.
2. Ejecuta `make start-server`.
3. Ejecuta `make password` y copia la password al portapapeles.
4. Accede a http://localhost:8080 y usa la password anterior.
5. Completa el asistente de configuración inicial:
    1. Instala los _plugins_ sugeridos por defecto.
    2. Ignora la creación de un usuario administrador.
    3. Acepta la configuración de una URL preconfigurada.
6. Crea 3 agentes:
    1. `agent01`, con _remote root directory_ `/var/jenkins` y _label_ `docker`.
    2. `agent02`, con _remote root directory_ `/var/jenkins` y _label_ `maven`.
    3. `agent03`, con _remote root directory_ `/var/jenkins` y _label_ `node`.
7. Obtén los secretos de los agentes y cópialos en los ficheros correspondientes:
    1. `agent01` en `secrets/jenkins-agent-docker`.
    2. `agent02` en `secrets/jenkins-agent-maven`.
    3. `agent03` en `secrets/jenkins-agent-node`.
8. Ejecuta `make start-agents`.
9. Cuando termines de trabajar, ejecuta `make stop`.

**Nota**: Los secretos están disponibles en la página del agente. Jenkins muestra el
código que hay que ejecutar para arrancar el servicio del agente, y el secreto está
embebido en estos comandos, tal como se muestra en la imagen.

![agent-secret](/assets/jenkins-agent-secret.png)
