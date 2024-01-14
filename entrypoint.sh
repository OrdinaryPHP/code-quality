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
  qSuccess+=$?
fi

if [ "$RUN_STATIC_ANALYSIS" == "true" ]; then
  echo "Running static analysis (psalm)..."
  psalm
  qSuccess+=$?
fi

if [ "$RUN_CODE_STYLE" == "true" ]; then
  echo "Running code style checks (phpcs)..."
  phpcs
  qSuccess+=$?
fi

if [ "$RUN_UNIT_TESTS" == "true" ]; then
  echo "Running unit tests (phpunit)..."
  runPhpUnit=(phpunit)

  if [ -n "$TARGET_TEST_SUITE" ]; then
    echo "  Testsuite: $TARGET_TEST_SUITE"
    runPhpUnit+=(--testsuite "$TARGET_TEST_SUITE")
  fi

  "${runPhpUnit[@]}"
  qSuccess+=$?
fi

if [ $qSuccess -eq 0 ]; then
  echo "Code Quality Tests: Complete"
else
  echo "Code Quality Tests: Failed"
fi

exit $qSuccess
