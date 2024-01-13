ARG COMPOSER_VERSION=2.6
ARG PHP_VERSION=8.2
ARG LINUX_OS="alpine"

FROM composer:${COMPOSER_VERSION} as composer

FROM php:${PHP_VERSION}-cli-${LINUX_OS}

RUN apk update && apk add zip 7zip git bash

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
COPY phpunit.xml.dist phpunit.xml.dist
COPY tests tests
COPY default-quality-config default-quality-config
COPY entrypoint.sh entrypoint.sh

RUN composer validate && composer audit && composer install

ENV PATH="$PATH:/code-quality/bin:/code-quality/vendor/bin"

ENV RUN_LINT="true"
ENV RUN_STATIC_ANALYSIS="true"
ENV RUN_CODE_STYLE="true"
ENV RUN_UNIT_TESTS="true"
ENV TARGET_TEST_SUITE=""

WORKDIR /mnt/project

ENTRYPOINT [ "/code-quality/entrypoint.sh" ]
