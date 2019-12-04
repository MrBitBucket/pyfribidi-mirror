function pre_build {
	echo "===== pre_build ls($(pwd))"
	ls
	cd fribidi-src
	/opt/python/cp38-cp38/bin/pip install meson ninja
	/opt/python/cp38-cp38/bin/meson -Ddocs=false --backend=ninja build
	/opt/python/cp38-cp38/bin/ninja build test
	}

function run_tests {
	(
	echo -n "+++++ python version:";python -c"import sys;print(sys.version.split()[0])"
	echo -n "+++++ filesystemencoding:";python -c"import sys;print(sys.getfilesystemencoding())"
	cd ../pyfribidi/src
	echo "===== in reportlab/tests pwd=`pwd`"
	python test_pyfribidi.py
	)
	}
