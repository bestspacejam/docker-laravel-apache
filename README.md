# Laravel Apache Server

Образ для запуска приложений использующих фреймворк [Laravel](https://laravel.com/) с настроеным сервером Apache


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


*Пока не придумал как вызывать версию laravel-apache используемую в проекте, можно ставить пакеты через `docker-compose run`*


## Обновление пакетов

```shell
docker run \
  --rm \
  -v "$PWD":/var/www/html \
  -u $(id -u):$(id -g) \
  bestspacejam/laravel-apache \
  composer update
```


## Создание контроллеров аутентификации

```shell
docker run \
  --rm \
  -v "$PWD":/var/www/html \
  -u $(id -u):$(id -g) \
  bestspacejam/laravel-apache \
  php artisan make:auth
```


### Вход в консоль сервера

```shell
docker-compose exec -u $(id -u):$(id -g) webserver bash
```



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


## Docker Compose

**docker-compose.yml**

```yaml
version: "3"
services:
  webserver:
    image: registry.bestspacejam.ru/laravel-project
    build: application
    depends_on:
      - mariadb
    networks:
      backend:
      frontend:
        aliases:
          - laravel-project
  mariadb:
    image: mariadb:10.2
    networks:
      backend:
        aliases:
          - database.local
networks:
  backend:
  frontend:
    external: true
```


**docker-compose.prod.yml**

```yaml
version: "3"
services:
  webserver:
    restart: always
    volumes:
      - laravel-project-storage:/var/www/html/storage
    environment:
      MIGRATE: "true"
      APP_DEBUG: "false"
      DB_CONNECTION: mysql
      DB_HOST: mariadb
      DB_PORT: ""
      DB_DATABASE: main
      DB_USERNAME: user
      DB_PASSWORD: TA1i9JH756t8aN1I5W
  mariadb:
    restart: always
    volumes:
      - laravel-project-mariadb:/var/lib/mysql
    environment:
      # Имя базы данных создаваемой при инициализации
      MYSQL_DATABASE: main
      
      # Имя пользователя базы данных,
      # при инициализации ему даются все права на эту базу.
      MYSQL_USER: user
      MYSQL_PASSWORD: TA1i9JH756t8aN1I5W
      
      MYSQL_ROOT_PASSWORD: LCoHVtRnrEJY45TaD2C7
      MYSQL_ALLOW_EMPTY_PASSWORD: "no"
volumes:
  laravel-project-storage:
    external: true
  laravel-project-mariadb:
    external: true
```


**docker-compose.override.yml**

```yaml
version: "3"
services:
  webserver:
    # command: php -S 0.0.0.0:80 /var/www/html/server.php
    ports:
      - 8088:80
    volumes:
      - ./application:/var/www/html
      - ./storage:/var/www/html/storage
    tmpfs:
      # Hараметры 'mount' для нормальной работы временных директорий.
      #
      # По-умолчанию временный раздел монтируется с правами пользователя от имени которого запускается
      # контейнер. Процессы запущенные от www-data (Apache, PHP), не могут писать туда файлы.
      #
      # См. описание опций монтирования в разделе "Mount options for tmpfs":
      # https://linux.die.net/man/8/mount
      #
      # Директория "/var/www/.config" используется модулем tinker
      
      - "/var/www/.config:mode=1777"
    environment:
      CHECK_STORAGE: "true"
      MIGRATE: "true"
      APP_DEBUG: "true"
      DB_CONNECTION: mysql
      DB_HOST: mariadb
      DB_PORT: ""
      DB_DATABASE: "${MYSQL_DATABASE:-main}"
      DB_USERNAME: "${MYSQL_USER:-root}"
      DB_PASSWORD: "${MYSQL_PASSWORD}"
  mariadb:
    volumes:
      - ./mariadb:/var/lib/mysql
    environment:
      # Имя базы данных создаваемой при инициализации
      MYSQL_DATABASE: "${MYSQL_DATABASE:-main}"
      
      # Имя пользователя базы данных,
      # при инициализации ему даются все права на эту базу.
      MYSQL_USER: "${MYSQL_USER:-root}"
      MYSQL_PASSWORD: "${MYSQL_PASSWORD}"
      
      MYSQL_ROOT_PASSWORD: "${MYSQL_ROOT_PASSWORD}"
      MYSQL_ALLOW_EMPTY_PASSWORD: "${MYSQL_ALLOW_EMPTY_PASSWORD:-yes}"
  myadmin:
    image: phpmyadmin/phpmyadmin
    networks:
      - backend
    ports:
      - "8188:80"
    environment:
      PMA_HOST: mariadb
```


### Переменные окружения

- `CHECK_STORAGE` (true, "") - Проверка и создание дерева разделов в директории /storage
- `MIGRATE` (true, "") - Запуск миграций при запуске сервера
