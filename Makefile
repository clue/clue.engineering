build: vendor www/src/tailwind.min.css
	vendor/bin/sculpin generate

vendor: composer.json composer.lock
	composer install
	touch $@

www/src/tailwind.min.css: www/_layouts/* www/_posts/* www/_talks/* www/*.html www/*.html.twig tailwindcss tailwind.config.js
	./tailwindcss -o $@ --minify
	touch $@

tailwindcss:
	test -x tailwindcss || curl -L https://github.com/tailwindlabs/tailwindcss/releases/download/v3.2.4/tailwindcss-linux-x64 > tailwindcss && chmod +x tailwindcss

serve: build
	docker run -it --rm -p 80:80 -v "$$PWD"/build/:/var/www/html/ php:8.1-apache sh -c "ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled; apache2-foreground"

served: build
	docker run -d --rm -p 80:80 -v "$$PWD"/build/:/var/www/html/ php:8.1-apache sh -c "ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled; apache2-foreground"
	@sleep 2
	@echo Container running. Use \"docker rm -f {containerId}\" to stop container.

test:
	bash tests/acceptance.sh
	test -z "$$(git status --porcelain)" || (echo Directory is dirty && git status && exit 1)

clean:
	rm -rf build/ vendor/ tailwindcss

.PHONY: build serve served test clean
