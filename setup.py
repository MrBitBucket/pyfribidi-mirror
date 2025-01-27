try:
    from setuptools import setup, Extension, find_packages
except ImportError:
    from distutils.core import setup, Extension
import sys, os, subprocess, shutil

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

def lineList(L):
    return '\n     '+('\n     '.join((repr(_) for _ in L)))

def lineListDir(d):
    return lineList(os.listdir(d))

if sys.argv[0]=='setup.py' and sys.argv[1]=='sdist':
    ext_modules=[]
    data_files = [pjoin("src","_pyfribidi.c")]
    install_requires = ["meson","ninja","dulwich"]
else:
    install_requires = ["setuptools","meson","ninja","dulwich"]
    data_files = None
    def locationValueError(msg):
        print('!!!!! %s\nls(%r)\n%s\n!!!!!''' % (msg,cwd,lineListDir(cwd)))
        raise ValueError(msg)

    def sprun(args):
        print(f'##### about to execute\n  {" ".join(args)}')
        try:
            subprocess.run(args)
        except:
            t,e,b = sys.exc_info()
            print(f'!!!!! {args[0]} raised {e}')
            raise

    def getFribidiSrc():
        print(f'##### attempting git clone an meson/ninja build in {here}')
        try:
            target = 'fribidi-src'
            if os.path.isdir(target):
                shutil.rmtree(target)
                print(f'##### removed existing directory {target!r}')
            from dulwich import porcelain
            porcelain.clone("https://github.com/fribidi/fribidi", target, refspecs=[b'cfc71cda065db859d8b4f1e3c6fe5da7ab02469a'])
            cwd = os.getcwd()
            os.chdir(target)
            try:
                sprun(['meson','setup','-Ddocs=false','--backend=ninja','build'])
                sprun(['ninja','-C','build','test'])
            finally:
                os.chdir(cwd)
        except:
            t,e,b = sys.exc_info()
            print(f'!!!!! clone and build commands failed with {e}')
            raise
        else:
            return target

    fribidi_src = getFribidiSrc()
    pyfribidi_src = 'src'
    if verbose:
        print("+++++ fribidi_src=%r\n+++++ pyfribidi_src=%r" % (fribidi_src,pyfribidi_src))

    meson_lib = pjoin(fribidi_src,'build','lib')
    def getIncludeDirs():
        for _top in ('build',None):
            top = pjoin(fribidi_src,_top) if _top else fribidi_src
            lib = pjoin(top,'lib')
            if isfile(pjoin(top,'config.h')) and isfile(pjoin(lib,'fribidi-config.h')):
                I = [top,lib]
                if _top:
                    gen = pjoin(top,'gen.tab')
                    if isfile(pjoin(gen,'fribidi-unicode-version.h')):
                        I.append(gen)
                    return I
        locationValueError('''Cannot locate a suitable config.h file.
        meson setup -Ddocs=false --backend=ninja build
        ninja -C build test
    or
        ./autogen.sh
        ./configure''')
    include_dirs = getIncludeDirs() + [pjoin(fribidi_src,"lib"),pjoin(fribidi_src,'gen.tab'),pyfribidi_src]
    if verbose:
        print("+++++ include_dirs=%s" % lineList(include_dirs))

    if isdir(meson_lib):
        if sys.platform=='win32':
            if verbose:
                print('+++++ meson_lib ls(%r)\n%s' % (meson_lib,lineListDir(meson_lib)))
            meson_lib = pjoin(meson_lib,'fribidi.lib')
        else:
            meson_lib = pjoin(meson_lib,'libfribidi.a')

        if not isfile(meson_lib):
            meson_lib = None
    else:
        meson_lib = None


    libraries = []
    if meson_lib:
        extra_objects = [meson_lib]
        lib_sources = []
        if verbose:
            print('+++++ using static libraries %s' % lineList(libraries))
    else:
        extra_objects = []
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
    define_macros = [("HAVE_CONFIG_H", 1)]
    ext_modules=[
        Extension(
            name='pyfribidi._pyfribidi',
            sources=[pjoin("src",'_pyfribidi.c')] + lib_sources,
            define_macros=define_macros,
            libraries=libraries,
            extra_objects = extra_objects,
            include_dirs=include_dirs,
            ),
        ]

def get_version():
    with open(pjoin("src","pyfribidi","__init__.py"),"r") as f:
        for line in f.readlines():
            line = line.strip()
            if line.startswith('__version__'):
                version = eval(line.split('=')[1].strip(),{})

    if ext_modules:
        with open(pjoin("src","pyfribidi_version.h"),'w') as f:
            f.write('#define PYFRIBIDI_VERSION %s\n' % version)

    return version

setup(
    version=get_version(),
    ext_modules = ext_modules,
    long_description = open("README.rst").read(),
    packages = find_packages("src"),
    package_dir = {'': "src"},
    data_files = data_files,
    install_requires = install_requires,
    extras_require={},
)
