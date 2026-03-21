MOBILE_APP_DIR := apps/mobile_app
IOS_SIMULATOR ?= Travel Atlas iPhone 17 Pro

.PHONY: mobile-run mobile-run-ios mobile-test

mobile-run:
	cd $(MOBILE_APP_DIR) && flutter run

mobile-run-ios:
	cd $(MOBILE_APP_DIR) && flutter run -d "$(IOS_SIMULATOR)"

mobile-test:
	cd $(MOBILE_APP_DIR) && flutter test
