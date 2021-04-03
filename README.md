updateawskeys
=============

A bash script that uses aws cli to auto rotate your aws access and secret keys.

A Dockerfile that allows you to run it on Linux, Mac or Windows.

Requires one, and only one, active AWS key to work. The script uses the current key (specified by DO_DEFAULT being `true` or DO_SECTION specifying the key name in `~/.aws/credentials`) to create a new one, then uses https://github.com/magicalbob/configjsonconfig.git to update `~/.aws/credentials` with the new key (before deleting the old one).

The docker image takes 4 environment variables as input:

	DO_DEFAULT	must be true or false. If true will update the default section and
			the existing default keys will be used to run the aws cli.

	DO_SECTION	an optional section name in ~/.aws/credentials. Must be specified
			if DO_DEFAULT is false (in which case the existing DO_SECTION keys
			will be used to run the aws cli).

	UPDATE_DEFAULT  defaults to false. If set to true default key is changed(or inserted) to the new one,
                        even if DO_SECTION was used to run the aws cli.

	INSECURE_AWS    defaults to false. If set to true, includes aws cli option --no-verify-ssl.

build & run
===========

Example command to build the docker image:

	docker build -t local:updateawskeys .

Example command to run the docker image:

	docker run -e DO_DEFAULT=true -e DO_SECTION=my-key -v ${HOME}/.aws:/root/.aws local:updateawskeys

The script can be cron'ed to automatically change the keys e.g.

	```
	00 00 * * 1 /usr/bin/docker run -e DO_DEFAULT=true -e DO_SECTION=my-test-key -v ${HOME}/.aws:/root/.aws local:updateawskeys

	01 00 * * 2 /usr/bin/docker run -e DO_DEFAULT=false -e DO_SECTION=my-prod-key -v ${HOME}/.aws:/root/.aws local:updateawskeys
	```

It is best to run the updates `out of hours` so that changes are not made wjilst the keys are in use.
