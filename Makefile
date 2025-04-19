all:
	rm -rf ./public
	hugo build
	cp -r ./assets ./public/assets
