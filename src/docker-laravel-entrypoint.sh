#!/usr/bin/env bash
set -e

# Apache запускается от указанного пользователя и группы 
: ${APACHE_RUN_USER:=www-data}
export APACHE_RUN_USER

: ${APACHE_RUN_GROUP:=www-data}
export APACHE_RUN_GROUP


# Проверка и создание дерева разделов в директории /storage
# 
# Необходимо для работы сервера в режиме разработки, так как при "bind-mount"-монтировании 
# директории "/storage" дерево разделов хранилища слетает и Laravel начинает ругаться 
# на невозможность записать файлы.
# 
# Обработка флага true подсмотрена в скрипте:
# https://github.com/aspendigital/docker-octobercms/blob/master/php7.1/apache/docker-oc-entrypoint
if [ "${CHECK_STORAGE,,}" == "true" ]; then
    REQUIRED_STORAGE_DIRS=( \
        app{,/public}
        framework{,/cache,/views,/sessions,/testing} \
        logs \
        temp \
    )
    
    # При "bind-mount"-монтировании директории "/storage" ей выставляется владелец от которого 
    # запускается entrypoint-скрипт (по-умолчанию это root) и сервер запущенный от другого пользователя 
    # не может писать туда файлы.
    # Директория /storage является точкой наследования владельца для создаваемых подразделов.
    chown "$APACHE_RUN_USER:$APACHE_RUN_GROUP" storage

    cd storage
        mkdir -p "${REQUIRED_STORAGE_DIRS[@]}"
        
        # Выставление владельца всем подразделам по родительской директории.
        # Необходимо для разрешения веб-серверу запущенному не от суперпользователя писать файлы в /storage/*.
        chown $(stat -c "%u:%g" .) "${REQUIRED_STORAGE_DIRS[@]}"
    cd -
fi

# Запуск миграций при запуске сервера
if [ "${MIGRATE,,}" == "true" ]; then
    php artisan migrate
fi

# Запускается entrypoint скрипт родительского образа:
# https://github.com/docker-library/php/blob/master/7.2/stretch/apache/docker-php-entrypoint
exec docker-php-entrypoint "$@"