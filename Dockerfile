FROM martin2718/repro

# Install Node.js using nvm
# Specify the Node version
ENV NODE_VERSION=18.1.0
RUN curl --fail -sSf https://raw.githubusercontent.com/creationix/nvm/v0.39.1/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"

# Install Rust and Cargo in /opt
# Specify the Rust toolchain version
ARG rust_version=1.60.0
ENV RUSTUP_HOME=/opt/rustup \
    CARGO_HOME=/opt/cargo \
    PATH=/opt/cargo/bin:$PATH
RUN curl --fail https://sh.rustup.rs -sSf \
        | sh -s -- -y --default-toolchain ${rust_version}-x86_64-unknown-linux-gnu --no-modify-path && \
    rustup default ${rust_version}-x86_64-unknown-linux-gnu && \
    rustup target add wasm32-unknown-unknown
RUN cargo install ic-cdk-optimizer

# Install dfx; the version is picked up from the DFX_VERSION environment variable
ENV DFX_VERSION=0.10.0
RUN sh -ci "$(curl -fsSL https://smartcontracts.org/install.sh)"

RUN apt -yqq install --no-install-recommends reprotest disorderfs faketime rsync sudo wabt webpack

COPY . /canister
WORKDIR /canister

#RUN npm ci # if `package.json` is available in your canister directory
