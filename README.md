<br>

<div align="center">
<img width="456" src="https://raw.githubusercontent.com/wayofdev/docker-project-services/master/assets/logo.gh-light-mode-only.png#gh-light-mode-only" alt="Logo for light mode">
<img width="456" src="https://raw.githubusercontent.com/wayofdev/docker-project-services/master/assets/logo.gh-dark-mode-only.png#gh-dark-mode-only" alt="Logo for dark mode">
</div>
<br>
<br>

<div align="center">
<a href="https://actions-badge.atrox.dev/wayofdev/docker-project-services/goto"><img alt="Build Status" src="https://img.shields.io/endpoint.svg?url=https%3A%2F%2Factions-badge.atrox.dev%2Fwayofdev%2Fdocker-project-services%2Fbadge&style=flat-square"/></a>
<a href="https://github.com/wayofdev/docker-project-services/tags"><img src="https://img.shields.io/github/v/tag/wayofdev/docker-project-services?sort=semver&style=flat-square" alt="Latest Version"></a>
<a href="LICENSE.md"><img src="https://img.shields.io/github/license/wayofdev/docker-project-services.svg?style=flat-square&color=blue" alt="Software License"/></a>
<a href="#"><img alt="Commits since latest release" src="https://img.shields.io/github/commits-since/wayofdev/docker-project-services/latest?style=flat-square"></a>
</div>


<br>

# Docker Project Services

This Repository is used together with SOA based projects, consisting of microservices, built on [laravel-starter-tpl](https://github.com/wayofdev/laravel-starter-tpl).

### → Purpose

The purpose of this repository is to contain Docker services that can be shared across all microservices in one domain.

<br>

## 🚩 Requirements

* **macOS** Monterey or **Linux**
* **Docker** 20.10 or newer
  - [How To Install and Use Docker on Ubuntu 22.04](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-22-04)
* **Cloned, configured and running** [docker-shared-services](https://github.com/wayofdev/docker-shared-services), to support system-wide DNS, Routing and SSL support via Traefik.

<br>

## 💻 Usage

> **Warning**: Repository with [docker-shared-services](https://github.com/wayofdev/docker-shared-services) should be configured, up and running before

### → Instructions

1. Clone repository:

   ```bash
   $ git clone git@github.com:wayofdev/docker-project-services.git
   ```

2. Generate default .env file:

   ```bash
   # With custom namespace provided, it will be used to prefix all services
   # in Docker network for current project
   $ make env COMPOSE_PROJECT_NAME=bfq

   # Default project namespace will be used - **wod**
   $ make env
   ```

   Edit the created .env file if necessary. You may want to change the default domain.

3. (Optional) Enable the `docker-compose.override.yaml` file to run extra services, like pg-admin and others:
   ```bash
   $ make override
   ```

4. Run this repository:

   ```bash
   $ make up
   ```

5. Check that everything works:

   ```bash
   $ make ps
   $ make logs
   ```

<br>

## 🧪 Testing

You can check `Makefile` to get full list of commands for local testing. For testing, you can use these commands to test whole role or separate tasks:

Testing docker-compose using dcgoss:

```bash
$ make test
```

<br>

## 🤝 License

[![Licence](https://img.shields.io/github/license/wayofdev/docker-project-services?style=for-the-badge&color=blue)](./LICENSE)

<br>

## 🙆🏼‍♂️ Author Information

This repository was created in **2022** by [lotyp / wayofdev](https://github.com/wayofdev).

<br>

## 🫡 Contributors

<img align="left" src="https://img.shields.io/github/contributors-anon/wayofdev/docker-project-services?style=for-the-badge" alt="Contributors"/>

<a href="https://github.com/wayofdev/docker-nginx/graphs/contributors">
  <img src="https://opencollective.com/wod/contributors.svg?width=890&button=false" alt="Contributors">
</a>

<br>
