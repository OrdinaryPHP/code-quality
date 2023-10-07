#!/bin/sh

for config in .phplint.yml phpcs.xml.dist psalm.xml.dist; do
  if ! [ -f "$config" ]; then
    cp /code-quality/"$config" .
  fi
done


if [ -f ./php-ext-require.txt ]; then
  PHP_EXT_REQUIRE="$PHP_EXT_REQUIRE $(cat ./php-ext-require.txt)"
  PHP_EXT_REQUIRE=$PHP_EXT_REQUIRE
fi

if [ -n "$PHP_EXT_REQUIRE" ]; then
  # shellcheck disable=SC2086
  install-php-extensions $PHP_EXT_REQUIRE
fi

/code-quality/vendor/bin/phplint
/code-quality/vendor/bin/psalm
/code-quality/vendor/bin/phpcs
