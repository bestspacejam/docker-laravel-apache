# Laravel Apache Server

Образ для запуска приложений использующих фреймворк Laravel 5.5 с настроеным сервером Apache


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

