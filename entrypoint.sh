#!/bin/sh

for config in .phplint.yml phpcs.xml.dist psalm.xml.dist; do
  if ! [ -f "$config" ]; then
    echo "Copying default config $config"
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

echo "finding files"
find . -name '*.php' -not -path './vendor/*'
ls -l
echo "$PWD"

echo "Linting..."
/code-quality/vendor/bin/phplint -vvv
echo "Static analysis..."
/code-quality/vendor/bin/psalm
echo "Code style check..."
/code-quality/vendor/bin/phpcs
