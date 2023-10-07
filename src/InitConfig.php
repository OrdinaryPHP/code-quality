<?php

declare(strict_types=1);

namespace Ordinary\CodeQuality;

class InitConfig
{
    public function getPackagePath(?string $path): string
    {
        $result = dirname(__DIR__);
        $path = $path ? ltrim($path, '/\\') : null;

        return $path ? ($result . '/' . $path) : $result;
    }

    /** @return string[] */
    public function configFiles(): array
    {
        return [
            '.phplint.yml',
            'phpcs.xml.dist',
            'psalm.xml.dist',
        ];
    }

    public function copyConfig(): void
    {
        foreach ($this->configFiles() as $file) {
            copy($this->getPackagePath($file), $file);
        }
    }
}
