# To build this container:
# docker run -it -v $(pwd)/doc/:/documents/ adocbuilder asciidoctor-pdf -r asciidoctor-diagram mem-map.adoc

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
RUN gem install 'asciidoctor-diagram'

# batch convert files like this:
# docker run -it -v $(pwd):/documents/ adocbuilder asciidoctor-pdf -r asciidoctor-diagram myfile.adoc
