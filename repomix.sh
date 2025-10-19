#!/bin/bash
npx -y repomix --style markdown \
  --include 'demo/01/lib/**/*.dart,demo/01/pubspec.yaml,demo/01/integration_test/*.dart,demo/01/test/*.dart,automation/wdio.conf.js,mise.toml,*.sh,README.md,CLAUDE.md,AGENTS.md' \
  --ignore '**/build/**,**/.dart_tool/**,**/node_modules/**,**/.tmp/**,**/allure-results/**,**/Pods/**,demo/01/android/**,demo/01/ios/**,demo/01/macos/**,demo/01/web/**,demo/01/windows/**,demo/01/linux/**,repomix-output.md'
