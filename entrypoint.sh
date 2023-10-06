composer install
composer require vimeo/psalm --dev
composer require squizlabs/php_codesniffer --dev
composer require ordinary/coding-style --dev
composer require slevomat/coding-standard --dev
composer require overtrue/phplint --dev

for config in .phplint.yml phpcs.xml.dist psalm.xml.dist; do
  if ! [ -f "$config" ]; then
    cp /etc/code-quality/"$config" .
  fi
done

if [ -f ./php-ext-require.txt ]; then
  install-php-extensions $(cat ./php-ext-require.txt)
fi

vendor/bin/phplint
vendor/bin/psalm
vendor/bin/phpcs
