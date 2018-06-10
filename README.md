# Laravel Apache Server

Образ для запуска приложений использующих фреймворк Laravel 5.5 с настроеным сервером Apache


## Создание проекта для разработки

```shell
docker run \
  --rm \
  -v $PWD/application:/var/www/html \
  bestspacejam/laravel-apache \
  sh -c 'composer create-project --prefer-dist laravel/laravel . "5.5.*"'
  
```


## Установка дополнительных библиотек


```shell
docker run \
  --rm \
  -v $PWD/application:/var/www/html \
  bestspacejam/laravel-apache \
  sh -c 'composer require barryvdh/laravel-cors'
```

\* Пока не придумал как вызывать версию laravel-apache используемую в проекте. Можно ставить через `docker-compose run`


## Копирование конфигурации 

```shell
sudo chown -R $(id -u):$(id -g) application/

cp ./laravel-application/Dockerfile ./application

cp ./laravel-application/config/database.php application/config/

```


## Параметры инициализации сервера

- `CHECK_STORAGE` (true, "") - Проверка и создание дерева разделов в директории /storage
- `MIGRATE` (true, "") - Запуск миграций при запуске сервера


### Пример конфигурации для Docker Compose

Для первичной инициализации проекта и запуска в режиме разработки

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



## Минимальный Dockerfile

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