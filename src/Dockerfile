FROM php:7.2.0-apache-stretch

# Намерянно разнесено на две инструкции, так как первый RUN реже меняется
RUN set -x; \
    apt-get update && apt-get install -y \
        libpng-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev

RUN set -x; \
    docker-php-ext-configure gd \
        --with-freetype-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install \
        bcmath \
        gd \
        pdo_mysql \
        zip


## COMPOSER ##

# Взято из:
# https://github.com/composer/docker/blob/master/1.6/Dockerfile

RUN echo "memory_limit=-1" >> "$PHP_INI_DIR/php-cli.ini" \
    && echo "date.timezone=${PHP_TIMEZONE:-UTC}" >> "$PHP_INI_DIR/php-cli.ini"

ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /tmp
ENV COMPOSER_VERSION 1.6.2

RUN curl -s -f -L -o /tmp/installer.php https://raw.githubusercontent.com/composer/getcomposer.org/b107d959a5924af895807021fcef4ffec5a76aa9/web/installer \
    && php -r " \
       \$signature = '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061'; \
       \$hash = hash('SHA384', file_get_contents('/tmp/installer.php')); \
       if (!hash_equals(\$signature, \$hash)) { \
           unlink('/tmp/installer.php'); \
           echo 'Integrity check failed, installer is either corrupt or worse.' . PHP_EOL; \
           exit(1); \
       }" \
    && php /tmp/installer.php --no-ansi --install-dir=/usr/bin --filename=composer --version=${COMPOSER_VERSION} \
    && composer --ansi --version --no-interaction \
    && rm -rf /tmp/* /tmp/.htaccess


## APACHE ##

RUN a2enmod rewrite

# Идея взята отсюда:
# https://gist.github.com/vinnyfs89/8cb77bd6cc6bd3ace0b3576dc682a960
# Можно ещё прописать эту переменную в /etc/apache2/envvars
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Эти переменные заведены в родительском образе
ENV APACHE_RUN_USER  www-data
ENV APACHE_RUN_GROUP www-data

# Переменная заведена специально для этого образа
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

COPY docker-laravel-entrypoint.sh /usr/local/bin/

EXPOSE 80

ENTRYPOINT ["docker-laravel-entrypoint.sh"]
CMD ["apache2-foreground"]
