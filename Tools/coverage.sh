#!/usr/bin/env bash
for file in .build/debug/{List,Numbers}.build/*.o
do
  objectArg="${objectArg} --object $file"
done
if [[ "$OSTYPE" == "darwin"* ]]; then
  prefixCmd="xcrun"
fi
${prefixCmd} llvm-cov show --format=html --instr-profile .build/debug/codecov/default.profdata ${objectArg} > code-coverage-report.html


export COVERAGE_TEXT=`${prefixCmd} llvm-cov report --instr-profile .build/debug/codecov/default.profdata ${objectArg}`
export COMPILER_WARNING=`swift build | grep warning`
export COMPILER_WARNINGS=${COMPILER_WARNING:-"No warnings! :)"}
cat README.md.template | envsubst > README.md