#!/usr/bin/env bash

export CI=true

echo "Running Tests (Github):"
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

ordinary-code-quality --init

if [ "$RUN_LINT" == "true" ]; then
  phplint
  qSuccess+=$?
fi

if [ "$RUN_STATIC_ANALYSIS" == "true" ]; then
  psalm
  qSuccess+=$?
fi

if [ "$RUN_CODE_STYLE" == "true" ]; then
  phpcs
  qSuccess+=$?
fi

if [ "$RUN_UNIT_TESTS" == "true" ]; then
  runPhpUnit=(phpunit)

  if [ -n "$TARGET_TEST_SUITE" ]; then
    runPhpUnit+=(--testsuite "$TARGET_TEST_SUITE")
  fi

  "${runPhpUnit[@]}"
  qSuccess+=$?
fi

exit $qSuccess
