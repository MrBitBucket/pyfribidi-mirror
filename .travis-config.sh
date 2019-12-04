function pre_build {
	echo "+++++ pre_build start ls($(pwd))"
	ls
	(
	cd pyfribidi/fribidi-src
	export PATH="/opt/python/cp38-cp38/bin:$PATH"
	pip install meson ninja
	meson -Ddocs=false --backend=ninja build
	ninja -C build test
	)
	echo "+++++ pre_build end"
	}

function run_tests {
	echo "+++++ run_tests start ls($(pwd))"
	ls
	(
	echo -n "+++++ python version:";python -c"import sys;print(sys.version.split()[0])"
	echo -n "+++++ filesystemencoding:";python -c"import sys;print(sys.getfilesystemencoding())"
	cd ../pyfribidi/src
	python test_pyfribidi.py || true
	)
	echo "+++++ run_tests end"
	}
