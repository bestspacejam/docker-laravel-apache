# Laravel Apache Server

Образ для запуска приложений использующих фреймворк Laravel 5.5 с настроеным сервером Apache


## Создание проекта для разработки

```shell
docker run \
  --rm \
  -v "$PWD":/var/www/html \
  -u $(id -u):$(id -g) \
  bestspacejam/laravel-apache \
  composer create-project --prefer-dist laravel/laravel . "5.5.*"
```


## Установка дополнительных библиотек


```shell
docker run \
  --rm \
  -v "$PWD":/var/www/html \
  -u $(id -u):$(id -g) \
  bestspacejam/laravel-apache \
  composer require barryvdh/laravel-cors
```


## Обновление пакетов

```shell
docker run \
  --rm \
  -v "$PWD":/var/www/html \
  -u $(id -u):$(id -g) \
  bestspacejam/laravel-apache \
  composer update
```


*Пока не придумал как вызывать версию laravel-apache используемую в проекте, можно ставить пакеты через `docker-compose run`*


## Dockerfile

```Dockerfile
FROM bestspacejam/laravel-apache:0.0.1

ENV WORKDIR /var/www/html

WORKDIR ${WORKDIR}
VOLUME ${WORKDIR}/storage

# Владелец должен совпадать с пользователем от которого запущен сервер
# (задаётся через переменные окружения APACHE_RUN_USER и APACHE_RUN_GROUP)
COPY --chown=www-data:www-data . .

EXPOSE 80
```


## Docker Compose

Пример `docker-compose.yml` для инициализации файловой структуры хранилища проекта и запуска в режиме разработки:

```yaml
version: "3"
services:
  webserver:
    volumes:
      - ./application:/var/www/html
      - ./storage:/var/www/html/storage
    environment:
      CHECK_STORAGE: "true"
      MIGRATE: "true"

```


### Переменные окружения

- `CHECK_STORAGE` (true, "") - Проверка и создание дерева разделов в директории /storage
- `MIGRATE` (true, "") - Запуск миграций при запуске сервера
