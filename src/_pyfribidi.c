/*
 *	This program is free software; you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation; either version 2 of the License, or
 *	(at your option) any later version.
 *
 *	This program is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *
 *	You should have received a copy of the GNU General Public License
 *	along with this program; if not, write to the Free Software
 *	Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

/* Copyright (C) 2005,2006,2010 Yaacov Zamir, Nir Soffer */

#include <Python.h>
#define __STR(x) #x
#define STRINGIFY(x) __STR(x)
#ifndef PYFRIBIDI_VERSION
#	define PYFRIBIDI_VERSION ?.?.?
#endif
#if PY_MAJOR_VERSION >= 3
#	define isPy3
#endif
#include <fribidi.h>

#ifdef isPy3
#	define CMODNAME PyInit__pyfribidi
#	define PYUNICODE_GET_LENGTH PyUnicode_GET_LENGTH
#else
#	define CMODNAME init_pyfribidi
#	define PYUNICODE_GET_LENGTH PyUnicode_GET_SIZE
#endif

static PyObject *unicode_log2vis(PyUnicodeObject* u,
								FriBidiParType base_direction,
								int clean, int reordernsm){
	Py_ssize_t length = PYUNICODE_GET_LENGTH(u), i;
	FriBidiChar *logical = NULL;	/* input fribidi unicode buffer */
	FriBidiChar *visual = NULL;		/* output fribidi unicode buffer */
#ifdef isPy3
	void *data = NULL;
	int	kind;
#	define READ(i) PyUnicode_READ(kind,data,i) 
#	define RESULT_TYPE PyObject
#else
#	define READ(i) u->str[i]
#	define RESULT_TYPE PyUnicodeObject
#endif
	RESULT_TYPE *result = NULL;

	/* Allocate fribidi unicode buffers
	   TODO - Don't copy strings if sizeof(FriBidiChar) == sizeof(Py_UNICODE)
	*/
	if(!(logical=PyMem_New(FriBidiChar, length + 1))){
		PyErr_NoMemory();
		goto cleanup;
		}

	if(!(visual=PyMem_New(FriBidiChar, length + 1))){
		PyErr_NoMemory();
		goto cleanup;
		}

#ifdef isPy3
	if(PyUnicode_READY(u)) goto cleanup;
	data = PyUnicode_DATA(u);
	kind = PyUnicode_KIND(u);
#endif
	for(i=0; i<length; ++i){
		logical[i] = READ(i);
		}

	/* Convert to unicode and order visually */
	fribidi_set_reorder_nsm(reordernsm);

	if(!fribidi_log2vis(logical, (const FriBidiStrIndex)length, &base_direction, visual, NULL, NULL, NULL)){
		PyErr_SetString(PyExc_RuntimeError, "fribidi failed to order string");
		goto cleanup;
		}

	/* Cleanup the string if requested */
	if(clean) length = fribidi_remove_bidi_marks(visual, (const FriBidiStrIndex)length, NULL, NULL, NULL);
#ifdef isPy3
	result = PyUnicode_FromKindAndData(PyUnicode_4BYTE_KIND,(void*)visual, length);
#else
	if(!(result=(PyUnicodeObject*)PyUnicode_FromUnicode(NULL, length))) goto cleanup;
	for(i=0; i<length; ++i){
		result->str[i] = visual[i];
		}
#endif

cleanup:
	/* Delete unicode buffers */
	PyMem_Del(logical);
	PyMem_Del(visual);

	return (PyObject *)result;
	}

static PyObject * _pyfribidi_log2vis(PyObject * self, PyObject * args, PyObject * kw){
	PyUnicodeObject *logical=NULL;	/* input unicode or string object */
	FriBidiParType base = FRIBIDI_TYPE_RTL;	/* optional direction */
	int clean = 0; /* optional flag to clean the string */
	int reordernsm = 1; /* optional flag to allow reordering of non spacing marks*/

	static char *kwargs[] = { "logical", "base_direction", "clean", "reordernsm", NULL };

	if(!PyArg_ParseTupleAndKeywords(args, kw, "U|iii", kwargs, &logical, &base, &clean, &reordernsm))
		return NULL;

	/* Validate base */
	if(!(base == (FriBidiParType)FRIBIDI_TYPE_RTL
	  || base == (FriBidiParType)FRIBIDI_TYPE_LTR
	  || base == (FriBidiParType)FRIBIDI_TYPE_ON
	  || base == (FriBidiParType)FRIBIDI_TYPE_WRTL
	  || base == (FriBidiParType)FRIBIDI_TYPE_WLTR
	  ))
		return PyErr_Format(PyExc_ValueError, "invalid value %d: use either RTL, LTR or ON", base);


	return unicode_log2vis(logical, base, clean, reordernsm);
	}

static PyMethodDef PyfribidiMethods[] = {
	{"log2vis", (PyCFunction) _pyfribidi_log2vis, METH_VARARGS | METH_KEYWORDS, NULL},
	{NULL, NULL, 0, NULL}
	};

#ifdef isPy3
static struct PyModuleDef moduledef={
	PyModuleDef_HEAD_INIT,
	"_pyfribidi",
	NULL,
	0,
	PyfribidiMethods,
	NULL,
	NULL,
	NULL,
	NULL
	};
#endif

PyMODINIT_FUNC CMODNAME(void){
	PyObject *module=NULL;
#ifdef isPy3
	module = PyModule_Create(&moduledef);
#else
	module = Py_InitModule("_pyfribidi", PyfribidiMethods);
#endif
	if(!module) goto err;
	if(		PyModule_AddIntConstant(module, "RTL", (long)FRIBIDI_TYPE_RTL)
		||	PyModule_AddIntConstant(module, "LTR", (long)FRIBIDI_TYPE_LTR)
		||	PyModule_AddIntConstant(module, "ON", (long)FRIBIDI_TYPE_ON)
		||	PyModule_AddIntConstant(module, "WLTR", (long)FRIBIDI_PAR_WLTR)
		||	PyModule_AddIntConstant(module, "WRTL", (long)FRIBIDI_PAR_WRTL)
		||	PyModule_AddStringConstant(module, "pyFribidiVersion", (const char *)STRINGIFY(PYFRIBIDI_VERSION))
		||	PyModule_AddStringConstant(module, "fribidiVersion", (const char *)FRIBIDI_VERSION)
		||	PyModule_AddStringConstant(module, "fribidiInterfaceVersion", (const char *)FRIBIDI_INTERFACE_VERSION_STRING)
		||	PyModule_AddStringConstant(module, "fribidiUnicodeVersion", (const char *)FRIBIDI_UNICODE_VERSION)
		)
		goto err;
#ifdef isPy3
	return module;
#else
	return;
#endif
err:/*Check for errors*/
#ifdef isPy3
	Py_XDECREF(module);
	return NULL;
#else
	if(PyErr_Occurred())Py_FatalError("can't initialize module _pyfribidi");
#endif
	}
