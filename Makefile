build: vendor www/src/tailwind.min.css
	vendor/bin/sculpin generate

vendor: composer.json composer.lock
	composer install
	touch $@

www/src/tailwind.min.css: www/_layouts/* www/_posts/* www/_talks/* www/*.html www/*.html.twig tailwind.config.js
	docker compose run --rm --build tailwind -o $@ --minify
	touch $@

test:
	bash tests/integration.bash http://clue.localhost/
	test -z "$$(git status --porcelain)" || (echo Directory is dirty && git status && exit 1)

deploy:
	git -C build/ init
	git -C build/ checkout live 2>/dev/null || git -C build/ checkout -b live
	git -C build/ add --all
	git -C build/ diff-index HEAD >/dev/null 2>/dev/null || git -C build/ commit -m "Website build"
	git -C build/ remote get-url origin >/dev/null 2>/dev/null || git -C build/ remote add origin $(shell git remote get-url origin)
	git -C build/ push origin live -f

clean:
	rm -rf build/ vendor/
	docker compose down --remove-orphans --rmi local

.PHONY: build test deploy clean
