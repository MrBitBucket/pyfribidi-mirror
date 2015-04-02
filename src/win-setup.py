import distutils
try:
    from setuptools import setup, Extension
except ImportError:
    from distutils.core import setup, Extension
import os

lib_sources = """
fribidi-src/lib/fribidi.c
fribidi-src/lib/fribidi-arabic.c
fribidi-src/lib/fribidi-bidi.c
fribidi-src/lib/fribidi-bidi-types.c
fribidi-src/lib/fribidi-deprecated.c
fribidi-src/lib/fribidi-joining.c
fribidi-src/lib/fribidi-joining-types.c
fribidi-src/lib/fribidi-mem.c
fribidi-src/lib/fribidi-mirroring.c
fribidi-src/lib/fribidi-run.c
fribidi-src/lib/fribidi-shape.c
fribidi-src/charset/fribidi-char-sets-cp1256.c
fribidi-src/charset/fribidi-char-sets-iso8859-8.c
fribidi-src/charset/fribidi-char-sets-cap-rtl.c
fribidi-src/charset/fribidi-char-sets-utf8.c
fribidi-src/charset/fribidi-char-sets.c
fribidi-src/charset/fribidi-char-sets-cp1255.c
fribidi-src/charset/fribidi-char-sets-iso8859-6.c
""".split()
libraries = []
include_dirs = ["fribidi-src", "fribidi-src/lib", "fribidi-src/charset","fribidi-src/win"]
define_macros = [("HAVE_CONFIG_H", 1)]

def get_version():
    d = {}
    try:
        with open("pyfribidi.py","r") as f:
            exec(f.read(), d, d)
    except (ImportError, RuntimeError):
        pass
    return d["__version__"]

setup(name="pyfribidi",
  version=get_version(),
  description="Python libfribidi interface",
  author="Yaacov Zamir, Nir Soffer",
  author_email="kzamir@walla.co.il",
  url="https://github.com/pediapress/pyfribidi",
  license="GPL",
  long_description=open("README.rst").read(),
  py_modules=["pyfribidi", "pyfribidi2"],
  ext_modules=[Extension(
        name='_pyfribidi',
        sources=['pyfribidi.c'] + lib_sources,
        define_macros=define_macros,
        libraries=libraries,
        include_dirs=include_dirs)])
