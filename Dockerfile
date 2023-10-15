ARG INPUT_COMPOSER_VERSION=2.6
ARG INPUT_PHP_VERSION=8.2
ARG INPUT_LINUX_OS="alpine"

FROM composer:${INPUT_COMPOSER_VERSION} as composer

FROM php:${INPUT_PHP_VERSION}-cli-${INPUT_LINUX_OS}

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions zip pcntl soap xdebug pcov igbinary intl

COPY --from=composer /usr/bin/composer /usr/bin/composer

WORKDIR /code-quality

COPY src src
COPY bin bin
COPY composer.json composer.json
COPY .phplint.yml .phplint.yml
COPY psalm.xml.dist psalm.xml.dist
COPY phpcs.xml.dist phpcs.xml.dist
COPY default-quality-config default-quality-config

RUN composer validate && composer audit && composer install

ENV PATH="$PATH:/code-quality/bin:/code-quality/vendor/bin"
