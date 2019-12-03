function pre_build {
	echo "===== pre_build ls($(pwd))"
	ls
	echo "===== pre_build ls(/opt)"
	ls /opt
	cd fribidi-src
	./autogen.sh
	./configure
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
