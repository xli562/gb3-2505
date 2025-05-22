include /gb3-2505/conf/setup.conf

.PHONY: \
	softwareblink \
	hardwareblink \
	bubblesort \
	upload \
	clean

softwareblink:
	cd softwareblink; make clean; make; make install
	cd processor; make

hardwareblink:
	cd hardwareblink; make clean; make;

bubblesort:
	cd bubblesort; make clean; make; make install
	cd processor; make

upload:
	sudo iceprog -S build/design.bin

clean:
	cd processor; make clean
	rm -f build/*.bin

clean-all-sw:
	@for dir in $(shell find $(SW_ROOT) -mindepth 1 -maxdepth 1 -type d ! -name 'include' -exec basename {} \;); do \
		echo "cleaning $$dir..."; \
		$(MAKE) -sC $(SW_ROOT) clean sw=$$dir  || exit $$?; \
	done
	@echo "done."
