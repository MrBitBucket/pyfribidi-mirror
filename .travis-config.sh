function pre_build {
	echo "+++++ pre_build start ls($(pwd))"
	ls
	(
	if [ -n "$IS_OSX" ]; then
		local opath="$PATH"
		local opython="$PYTHON_EXE"
    	export CC=clang
	    export CXX=clang++
	    get_macpython_environment 3.8 my-venv
	    source my-venv/bin/activate
	    pip install --upgrade pip wheel
		pip install meson ninja
		cd pyfribidi/fribidi-src
		meson -Ddocs=false --backend=ninja build
		ninja -C build test
		PATH="$opath"
		PYTHON_EXE="$opython"
	else
		export PATH="/opt/python/cp38-cp38/bin:$PATH"
		cd pyfribidi/fribidi-src
		pip install meson ninja
		meson -Ddocs=false --backend=ninja build
		ninja -C build test
	fi
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
