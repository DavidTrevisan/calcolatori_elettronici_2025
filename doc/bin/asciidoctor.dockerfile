FROM asciidoctor/docker-asciidoctor

LABEL mantainer="David Trevisan david.trevisan@vemd.it"

# ======= Instructions =======
# To build the docker image use the following command:
# docker build -f ./<filename>.dockerfile . --network=host -t <desired image name>
#
# e.g.:
# docker build -f ./asciidoctor.dockerfile . --network=host -t adocbuilder
#
# To interactively run the image (for debugging purposes):

# Edit accordingly

# Setup wavedrom-cli
RUN apk add --update nodejs npm
RUN npm i wavedrom-cli -g

# Setup asciidoctor-diagram
RUN apk add --no-cache ruby ruby-dev build-base
RUN gem install asciidoctor-diagram
RUN gem install asciidoctor-lists

# Install Rust and svgbob_cli
RUN apk add --no-cache curl
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

# Add Cargo bin path to environment
ENV PATH="/root/.cargo/bin:${PATH}"

# Install svgbob_cli via cargo
RUN /root/.cargo/bin/cargo install svgbob_cli

# batch convert files like this:
# docker run -it -v $(pwd):/documents/ adocbuilder asciidoctor-pdf -r asciidoctor-diagram myfile.adoc
