build: vendor
	vendor/bin/sculpin generate

vendor: composer.json composer.lock
	composer install
	touch $@

serve: build
	docker run -it --rm -p 80:80 -v "$$PWD"/build/:/var/www/html/ php:8.1-apache sh -c "ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled; apache2-foreground"

served: build
	docker run -d --rm -p 80:80 -v "$$PWD"/build/:/var/www/html/ php:8.1-apache sh -c "ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled; apache2-foreground"
	@sleep 2
	@echo Container running. Use \"docker rm -f {containerId}\" to stop container.

test:
	bash tests/acceptance.sh

clean:
	rm -rf build/ vendor/

.PHONY: build serve served test clean
