ARG INPUT_COMPOSER_VERSION=2.6
ARG INPUT_PHP_VERSION=8.2
ARG INPUT_LINUX_OS="alpine"

FROM composer:${INPUT_COMPOSER_VERSION} as composer

FROM php:${INPUT_PHP_VERSION}-cli-${INPUT_LINUX_OS}

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions zip

COPY --from=composer /usr/bin/composer /usr/bin/composer

COPY .phplint.yml /etc/ordinary-php/.phplint.yml
COPY psalm.xml.dist /etc/ordinary-php/psalm.xml.dist
COPY phpcs.xml.dist /etc/ordinary-php/phpcs.xml.dist

COPY entrypoint.sh /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
