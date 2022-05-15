# Build Stage
FROM --platform=linux/amd64 ubuntu:20.04 as builder

## Install build dependencies.
RUN (apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y cmake clang git)
RUN ( git clone https://github.com/aquynh/capstone.git && \
	cd capstone && \ 
	git checkout v4 && \ 
	make && \ 
	make install) 

## Add source code to the build stage.
ADD . /src
WORKDIR /src

## TODO: ADD YOUR BUILD INSTRUCTIONS HERE.
RUN make Makefile 
RUN chmod +x compile_libfuzzer.sh 
RUN ./compile_libfuzzer.sh
RUN chmox +x run_libfuzzer.sh
RUN ./run_libfuzzer.sh
# Package Stage
FROM --platform=linux/amd64 ubuntu:20.04

## TODO: Change <Path in Builder Stage>
COPY --from=builder /libxdc/libfuzzer_bin /

RUN run_libfuzzer.sh 
