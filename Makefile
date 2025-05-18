ci: clean deps lint test

define python_venv
	. .venv/bin/activate && $(1)
endef

clean:
	rm -rf stage/

rmdeps:
	rm -rf .venv/

deps:
	python3 -m venv .venv
	$(call python_venv,python3 -m pip install -r requirements.txt)

deps-upgrade:
	python3 -m venv .venv
	$(call python_venv,python3 -m pip install -r requirements-dev.txt)
	$(call python_venv,pip-compile --upgrade)

lint:
	$(call python_venv,molecule lint)

test:
	$(call python_venv,molecule test)

x-gen-vars-file:
	$(call python_venv,python3 scripts/gen-vars-file.py)

.PHONY: ci clean rmdeps deps deps-upgrade lint test x-gen-vars-file
