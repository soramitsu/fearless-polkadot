# This is the build stage for Polkadot. Here we create the binary in a temporary image.
FROM docker.io/paritytech/ci-linux:production as builder
ARG POLKADOT_COMMIT
WORKDIR /polkadot
COPY . /polkadot

RUN git checkout ${POLKADOT_COMMIT} && cargo build --locked --release

# This is the 2nd stage: a very small image where we copy the Polkadot binary."
FROM docker.io/library/ubuntu:20.04

COPY --from=builder /polkadot/target/release/polkadot /usr/local/bin
RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y \
		libssl1.1 \
		ca-certificates \
		curl bash && \
# apt cleanup
	apt-get autoremove -y && \
	apt-get clean && \
	find /var/lib/apt/lists/ -type f -not -name lock -delete
RUN useradd -m -u 10000 -U -s /bin/sh -d /polkadot polkadot && \
	mkdir -p /chain /polkadot/.local/share && \
	chown -R polkadot:polkadot /chain && \
	ln -s /chain /polkadot/.local/share/polkadot && \
# check if executable works in this container
	/usr/local/bin/polkadot --version

USER polkadot

EXPOSE 30333 9933 9944 9615
VOLUME ["/data"]

ENTRYPOINT ["/usr/local/bin/polkadot"]
