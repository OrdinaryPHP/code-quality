#!/usr/bin/env bash

export CI=true

echo "Running Tests (image):"
echo "  Lint: $RUN_LINT"
echo "  Static Analysis: $RUN_STATIC_ANALYSIS"
echo "  Code Style: $RUN_CODE_STYLE"
echo "  Unit Tests: $RUN_UNIT_TESTS"

if [ "$RUN_UNIT_TESTS" == "true" ]; then
  if [ -n "$TARGET_TEST_SUITE" ]; then
    echo "    Test Suite: $TARGET_TEST_SUITE"
  else
    echo "    **Running All Tests**"
  fi
fi

qSuccess=0

if [ -f composer.json ]; then
  composer validate -vvv
  qSuccess+=$?
  composer install --no-dev
  qSuccess+=$?
fi

ordinary-code-quality init

if [ "$RUN_LINT" == "true" ]; then
  echo "Running lint (phplint)..."
  phplint
  lintSuccess=$?
  qSuccess+=$lintSuccess

  if [ $lintSuccess -eq 0 ]; then
    echo "Linting: Succeeded"
  else
    echo "Linting: Failed"
  fi
fi

if [ "$RUN_STATIC_ANALYSIS" == "true" ]; then
  echo "Running static analysis (psalm)..."
  psalm
  analysisSuccess=$?
  qSuccess+=$analysisSuccess

  if [ $analysisSuccess -eq 0 ]; then
    echo "Static Analysis: Succeeded"
  else
    echo "Static Analysis: Failed"
  fi
fi

if [ "$RUN_CODE_STYLE" == "true" ]; then
  echo "Running code style checks (phpcs)..."
  phpcs
  styleSuccess=$?
  qSuccess+=$styleSuccess
  if [ $styleSuccess -eq 0 ]; then
    echo "Code Style Check: Succeeded"
  else
    echo "Code Style Check: Failed"
  fi
fi

if [ "$RUN_UNIT_TESTS" == "true" ]; then
  echo "Running unit tests (phpunit)..."
  runPhpUnit=(phpunit)

  if [ -n "$TARGET_TEST_SUITE" ]; then
    echo "  Testsuite: $TARGET_TEST_SUITE"
    runPhpUnit+=(--testsuite "$TARGET_TEST_SUITE")
  fi

  "${runPhpUnit[@]}"
  unitTestSuccess=$?
  qSuccess+=$unitTestSuccess

  if [ $unitTestSuccess -eq 0 ]; then
    echo "Unit Tests: Succeeded"
  else
    echo "Unit Tests: Failed"
  fi
fi

if [ $qSuccess -eq 0 ]; then
  echo "Code Quality Tests: Succeeded"
else
  echo "Code Quality Tests: Failed"
fi

exit $qSuccess
