CRATE_VERSION := `cargo pkgid | cut -d "#" -f2`
MESSAGE_CRATE_VERSION := `cd tire_monitor_messages && cargo pkgid | cut -d "#" -f2`
LAST_MESSAGE_CRATE_TAG := `git describe --tags --match 'messages-v*' --abbrev=0`

publish-message-crate:
	cd tire_monitor_messages && cargo semver-checks --baseline-rev {{LAST_MESSAGE_CRATE_TAG}} && cargo publish
	git tag messages-v{{MESSAGE_CRATE_VERSION}}

build-image:
	docker build . -t localhost:5432/tire_monitor:{{CRATE_VERSION}} --network=host

publish-image:
	docker push localhost:5432/tire_monitor:{{CRATE_VERSION}}