# EcoTrack — developer shortcuts. `make help` lists targets.
.DEFAULT_GOAL := help
.PHONY: help bootstrap env gen gen-watch run-dev run-staging run-prod \
        build-android build-ios build-web run-web test analyze format clean

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	 awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'

bootstrap: env ## First-time setup: env files + pub get + codegen
	flutter pub get
	dart run build_runner build

gen: ## Run code generation (drift / injectable / freezed / json)
	dart run build_runner build

gen-watch: ## Watch and regenerate on change
	dart run build_runner watch

env: ## Create local .env.* from the template (no-op if present)
	@for e in dev staging prod; do \
	  [ -f .env.$$e ] || cp .env.example .env.$$e && echo "created .env.$$e"; \
	done

run-dev: ## Run the dev flavor
	flutter run --flavor dev -t lib/main_dev.dart

run-staging: ## Run the staging flavor
	flutter run --flavor staging -t lib/main_staging.dart

run-prod: ## Run the prod flavor
	flutter run --flavor prod -t lib/main_prod.dart

build-android: ## Release App Bundle (prod)
	flutter build appbundle --flavor prod -t lib/main_prod.dart --release

build-ios: ## Release IPA (prod, unsigned — signing handled by Fastlane match)
	flutter build ios --flavor prod -t lib/main_prod.dart --release --no-codesign

run-web: ## Run the web dashboard (dev, Chrome)
	flutter run -d chrome --target lib/main_dev.dart

build-web: ## Release web build (prod entrypoint)
	flutter build web --target lib/main_prod.dart --release --pwa-strategy offline-first

test: ## Unit + widget tests with coverage
	flutter test --coverage

analyze: ## Static analysis
	flutter analyze

format: ## Format all Dart sources
	dart format .

clean: ## Nuke build artifacts
	flutter clean
