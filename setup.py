import distutils
try:
    from setuptools import setup, Extension
except ImportError:
    from distutils.core import setup, Extension
import sys,os

pjoin=os.path.join
isfile = os.path.isfile
isdir = os.path.isdir
verbose=int(os.environ.get("SETUP_VERBOSE","0"))

here = os.path.dirname(sys.argv[0])
cwd = os.getcwd()
if verbose:
    print("+++++ sys.argv=%r dirname=%r cwd=%r" % (sys.argv,here,cwd))

if not here:
    here = cwd

here = os.path.normpath(here)
if verbose:
    print("+++++ here=%r" % (here,))

def locationValueError(msg):
    print('!!!!! %s\nls(%r)\n%s\n!!!!!''' % (msg,os.getcwd(),os.listdir()))
    raise ValueError(msg)

def getFribidiSrc():
    choices = (
            pjoin(here,'..','fribidi-src'),
            pjoin(here,'fribidi-src'),
            )
    for d in choices:
        if isdir(d) and isfile(pjoin(d,'lib','fribidi-common.h')):
            return d
    locationValueError('Cannot locate fribidi-src directory from %s' % ' '.join((repr(d) for d in choices)))

fribidi_src = getFribidiSrc()
pyfribidi_src = pjoin(here,'src')
if verbose:
    print("+++++ fribidi_src=%r pyfribidi_src=%r" % (fribidi_src,pyfribidi_src))

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
def getIncludeDirs():
    for top in ('build',None):
        top = pjoin(fribidi_src,top) if top else top
        lib = pjoin(top,'lib')
        if isfile(pjoin(top,'config.h')) and isfile(pjoin(lib,'fribidi-config.h')):
            return [top,lib]
    locationValueError('''Cannot locate a suitable config.h file.
    meson -Ddocs=false --backend=ninja build
    ninja -C build test
or
    ./autogen.sh
    ./configure''')

include_dirs = getIncludeDirs() + [pjoin(fribidi_src,"lib")]

def get_version():
    d = {}
    try:
        with open(pjoin(pyfribidi_src,"pyfribidi.py"),"r") as f:
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
  package_dir = {'':pyfribidi_src},
  py_modules=["pyfribidi", "pyfribidi2"],
  ext_modules=[Extension(
        name='_pyfribidi',
        sources=[pjoin(pyfribidi_src,'_pyfribidi.c')] + lib_sources,
        define_macros=define_macros,
        libraries=libraries,
        include_dirs=include_dirs)])
