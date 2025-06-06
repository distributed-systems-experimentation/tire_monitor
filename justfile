CRATE_VERSION := `grep '^version' Cargo.toml | head -n 1 | sed 's/version = "\(.*\)"/\1/'`

publish-message-crate:
	cd tire_monitor_messages && cargo semver-checks && cargo publish

build-image:
	docker build . -t localhost:5432/tire_monitor:{{CRATE_VERSION}} --network=host

publish-image:
	docker push localhost:5432/tire_monitor:{{CRATE_VERSION}}