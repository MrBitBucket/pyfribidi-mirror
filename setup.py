import distutils
try:
    from setuptools import setup, Extension
except ImportError:
    from distutils.core import setup, Extension
import sys,os

pjoin=os.path.join
here = os.path.dirname(sys.argv[0])
if not here:
    here = os.getcwd()

here = os.path.normpath(here)
fribidi_src = os.path.normpath(pjoin(here,'..','fribidi-src'))
if not os.path.isdir(fribidi_src):
    raise ValueError('Cannot locate fribdi-src directory %r' % fribidi_src)
if sys.platform!='win32' and not os.path.exists(pjoin(fribidi_src,"config.status")):
    raise ValueError('you need to configure and make in the %s directory' % fribidi_src)
src = pjoin(here,'src')

lib_sources = [pjoin(fribidi_src,p) for p in """
lib/fribidi.c
lib/fribidi-arabic.c
lib/fribidi-bidi.c
lib/fribidi-bidi-types.c
lib/fribidi-brackets.c
lib/fribidi-deprecated.c
lib/fribidi-joining.c
lib/fribidi-joining-types.c
lib/fribidi-mirroring.c
lib/fribidi-run.c
lib/fribidi-shape.c
lib/fribidi-char-sets-cp1256.c
lib/fribidi-char-sets-iso8859-8.c
lib/fribidi-char-sets-cap-rtl.c
lib/fribidi-char-sets-utf8.c
lib/fribidi-char-sets.c
lib/fribidi-char-sets-cp1255.c
lib/fribidi-char-sets-iso8859-6.c
""".split()]
libraries = []
include_dirs = [fribidi_src, pjoin(fribidi_src,"lib")]
if sys.platform=='win32':
    include_dirs.append(pjoin(here,'win'))

def get_version():
    d = {}
    try:
        with open(pjoin(src,"pyfribidi.py"),"r") as f:
            exec(f.read(), d, d)
    except (ImportError, RuntimeError):
        pass
    return d["__version__"]

pyFribidiVersion=get_version()
define_macros = [("HAVE_CONFIG_H", 1),("PYFRIBIDI_VERSION",'"%s"' % pyFribidiVersion)]

setup(name="pyfribidi",
  version=pyFribidiVersion,
  description="Python libfribidi interface",
  author="Yaacov Zamir, Nir Soffer, Robin Becker",
  author_email="kzamir@walla.co.il",
  url="https://github.com/pediapress/pyfribidi",
  license="GPL",
  long_description=open("README.rst").read(),
  package_dir = {'':src},
  py_modules=["pyfribidi", "pyfribidi2"],
  ext_modules=[Extension(
        name='_pyfribidi',
        sources=[pjoin(src,'_pyfribidi.c')] + lib_sources,
        define_macros=define_macros,
        libraries=libraries,
        include_dirs=include_dirs)])
