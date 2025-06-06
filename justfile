CRATE_VERSION := `cargo pkgid | cut -d "#" -f2`
MESSAGE_CRATE_VERSION := `cd tire_monitor_messages && cargo pkgid | cut -d "#" -f2`

publish-message-crate:
	cd tire_monitor_messages && cargo semver-checks --baseline-rev `git describe --tags --match 'messages-v*' --abbrev=0` && cargo publish
	git tag messages-v{{MESSAGE_CRATE_VERSION}}

build-image:
	docker build . -t localhost:5432/tire_monitor:{{CRATE_VERSION}} --network=host

publish-image:
	docker push localhost:5432/tire_monitor:{{CRATE_VERSION}}

publish-crate:
	cargo publish
	just build-image
	just publish-image
	git tag v{{CRATE_VERSION}}

check-version-bump *revision='origin/main':
	@if git diff --quiet {{revision}} HEAD -- */Cargo.toml */src/; then \
		echo "[NO_BUMP_REQUIRED] No changes in Cargo.toml or src/ files since v{{CRATE_VERSION}}, no need to bump version"; \
		exit 0; \
	else \
		echo "[BUMP_REQUIRED] changes in Cargo.toml or src/ files since v{{CRATE_VERSION}}, need to bump version"; \
		exit 1; \
	fi

clippy:
	cargo clippy --all-features -- -D warnings

test:
	cargo nextest r --all-features --no-tests warn

test-release:
	cargo nextest r --all-features --release --no-tests warn