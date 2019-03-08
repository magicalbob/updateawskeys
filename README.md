updateawskeys
=============

A bash script that uses aws cli to auto rotate your aws access and secret keys.

A Dockerfile that allows you to run it on Linux, Mac or Windows.

The docker image takes 2 environment variables as input:

	DO_DEFAULT	must be true or false. If true will update the default section and
			the existing default keys will be used to run the aws cli.

	DO_SECTION	an optional section name in ~/.aws/credentials. Must be specified
			if DO_DEFAULT is false (in which case the existing DO_SECTION keys
			will be used to run the aws cli).

build & run
===========

Example command to build the docker image:

	docker build -t local:updateawskeys .

Example command to run the docker image:

	docker run -e DO_DEFAULT=true -e DO_SECTION=my-key -v ${HOME}/.aws:/root/.aws local:updateawskeys
