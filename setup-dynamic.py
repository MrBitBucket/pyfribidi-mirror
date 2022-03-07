try:
    from setuptools import setup, Extension
except ImportError:
    from distutils.core import setup, Extension
import sys,os,glob

pjoin=os.path.join
normpath = os.path.normpath
isfile = os.path.isfile
isdir = os.path.isdir
verbose=int(os.environ.get("SETUP_VERBOSE","0"))

here = os.path.dirname(sys.argv[0])
cwd = os.getcwd()
if verbose:
    print("+++++ sys.argv=%r dirname=%r cwd=%r" % (sys.argv,here,cwd))

if not here:
    here = cwd

here = normpath(here)
if verbose:
    print("+++++ here=%r" % (here,))

def spaceList(L):
    return ' '.join((repr(_) for _ in L))

def spaceListDir(d):
    return spaceList(os.listdir(d))

def locationValueError(msg):
    print('!!!!! %s\nls(%r)\n%s\n!!!!!''' % (msg,cwd,spaceListDir(cwd)))
    raise ValueError(msg)

pyfribidi_src = pjoin(here,'src')
def get_version():
    d = {}
    try:
        with open(pjoin(pyfribidi_src,"pyfribidi.py"),"r") as f:
            exec(f.read(), d, d)
    except (ImportError, RuntimeError):
        pass
    return d["__version__"]
pyFribidiVersion=get_version()

def include_dirs():
    n = 0
    for d in ('/usr/local/include', '/usr/include'):
        dfi = pjoin(d,'fribidi')
        if os.path.isdir(dfi):
            yield dfi
            n += 1
    if not n:
        raise ValueError('could not find includes for fribidi')

def lib_dirs():
    n = 0
    for d in ('/usr/local/lib', '/usr/lib'):
        if glob.glob(pjoin(d,'libfribidi.*')):
            yield d
            n += 1
    if not n:
        raise ValueError('could not find dynamic library for fribidi')

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
    ext_modules=[
        Extension(
            name='_pyfribidi',
            sources=[pjoin(pyfribidi_src,'_pyfribidi.c')],
            define_macros=[('PYFRIBIDI_VERSION',pyFribidiVersion)],
            library_dirs = list(lib_dirs()),
            libraries=['fribidi'],
            extra_objects = [],
            include_dirs = list(include_dirs())
            ),
        ],
      )
