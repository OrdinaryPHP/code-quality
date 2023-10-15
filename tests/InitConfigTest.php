<?php

namespace Ordinary\CodeQuality;

use PHPUnit\Framework\TestCase;
use Random\Randomizer;

class InitConfigTest extends TestCase
{
    private static array $dirCleanup = [];

    public static function copyConfigProvider(): \Generator
    {
        yield [true];
        yield [false];
    }

    public function testCopyConfig(): void
    {
        $workdir = getcwd();
        $config = new InitConfig();

        $tmpA = self::tmpDir(sys_get_temp_dir(), "testCopyConfig-withfiles-");
        self::chdir($tmpA);

        $testContents = (new Randomizer())->getBytes(8);

        // create files with contents
        foreach ($config->configFiles() as $file) {
            file_put_contents($file, $testContents);
        }

        // copy with overwrite and test
        $config->copyConfig(true);

        foreach ($config->configFiles() as $file) {
            self::assertFileEquals($config->getPackagePath('/default-quality-config/' . $file), $file);
        }

        // reset file contents
        foreach ($config->configFiles() as $file) {
            file_put_contents($file, $testContents);
        }

        // copy without overwrite and test
        $config->copyConfig();

        foreach ($config->configFiles() as $file) {
            self::assertStringEqualsFile($file, $testContents);
        }

        $tmpB = self::tmpDir(sys_get_temp_dir(), 'testCopyConfig-withoutfiles-nooverwrite');
        self::chdir($tmpB);

        $config->copyConfig();
        foreach ($config->configFiles() as $file) {
            self::assertFileExists($file);
            self::assertFileEquals($config->getPackagePath('/default-quality-config/' . $file), $file);
        }

        $tmpC = self::tmpDir(sys_get_temp_dir(), 'testCopyConfig-withoutfiles-overwrite');
        self::chdir($tmpC);

        $config->copyConfig(true);
        foreach ($config->configFiles() as $file) {
            self::assertFileExists($file);
            self::assertFileEquals($config->getPackagePath('/default-quality-config/' . $file), $file);
        }

        self::chdir($workdir);
    }

    private static function chdir(string $dir): void
    {
        if (!chdir($dir)) {
            throw new \Exception('Failed to change directory to: ' . $dir);
        }
    }

    private static function tmpDir(string $directory, string $prefix): string
    {
        $path = tempnam($directory, $prefix);

        if ($path === false) {
            throw new \Exception('Fail to create temp file via tempnam()');
        }

        if (!unlink($path)) {
            throw new \Exception('Failed to unlink path for conversion to directory: ' . $path);
        }

        if (!mkdir($path, 0777, true)) {
            throw new \Exception('Failed to temp directory: ' . $path);
        }

        self::$dirCleanup[] = $path;

        return $path;
    }
}
