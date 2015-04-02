#!/usr/bin/python
# -*- coding: utf-8 -*-
'''
These are very basic tests, because fribidi has its own tests. It may be
better to reuse fribidi own tests, but its not clear what is the value
of base_dir for those tests.
'''

import sys
import unittest
import pyfribidi
from pyfribidi import RTL, LTR, ON

def U(b):
    return b.decode('utf8')

class TestSkipped(Exception):
    '''Raised when test can not run'''

class InputTests(unittest.TestCase):

    def testRequireInputString(self):
        '''input: require input string or unicode'''
        self.assertRaises(TypeError, pyfribidi.log2vis)

    def testInvalidInputString(self):
        '''input: raise TypeError for non string or unicode input'''
        self.assertRaises(TypeError, pyfribidi.log2vis, 1)

    def testInvalidDirection(self):
        '''input: raise ValueError for invalid direction'''
        self.assertRaises(ValueError, pyfribidi.log2vis, U(b'\xd7\xa9\xd7\x9c\xd7\x95\xd7\x9d'),
                          base_direction=1)

    def testUnknownEncoding(self):
        '''input: raise LookupError for invalid encoding'''
        self.assertRaises(LookupError, pyfribidi.log2vis, b'\xd7\xa9\xd7\x9c\xd7\x95\xd7\x9d',
                          encoding='foo')

    def testInvalidEncodedString(self):
        '''input: raise UnicodeError for invalid encoded string'''
        self.assertRaises(UnicodeError, pyfribidi.log2vis, b'\xd7\xa9\xd7\x9c\xd7\x95\xd7\x9d',
                          encoding='iso8859-8')

class UnicodeTests(unittest.TestCase):

    def testEmpty(self):
        '''unicode: empty string'''
        self.assertEqual(pyfribidi.log2vis(U(b'')), U(b''))

    def testBigString(self):
        '''unicode: big string

        It does not make sense to order such big strings, this just
        checks that there are no size limits in pyfribidi.
        '''
        # About 2MB string for default python build (ucs2)
        big = (U(b'\xd7\x90') * 1024) * 1024
        self.assertEqual(pyfribidi.log2vis(big), big)

    def testDefaultDirection(self):
        '''unicode: use RTL default'''
        self.assertEqual(pyfribidi.log2vis(U(b'hello - \xd7\xa9\xd7\x9c\xd7\x95\xd7\x9d')),
                         pyfribidi.log2vis(U(b'hello - \xd7\xa9\xd7\x9c\xd7\x95\xd7\x9d'), RTL))

    def testAsRTL(self):
        '''unicode: reorder line as RTL'''
        self.assertEqual(pyfribidi.log2vis(U(b'hello - \xd7\xa9\xd7\x9c\xd7\x95\xd7\x9d'), RTL),
                         U(b'\xd7\x9d\xd7\x95\xd7\x9c\xd7\xa9 - hello'))

    def testAsLTR(self):
        '''unicode: reorder line as LTR'''
        self.assertEqual(pyfribidi.log2vis(U(b'hello - \xd7\xa9\xd7\x9c\xd7\x95\xd7\x9d'), LTR),
                         U(b'hello - \xd7\x9d\xd7\x95\xd7\x9c\xd7\xa9'))

    def testNaturalLTR(self):
        '''unicode: reorder LTR line by natural order'''
        self.assertEqual(pyfribidi.log2vis(U(b'hello - \xd7\xa9\xd7\x9c\xd7\x95\xd7\x9d'), ON),
                         U(b'hello - \xd7\x9d\xd7\x95\xd7\x9c\xd7\xa9'))

    def testNaturalRTL(self):
        '''unicode: reorder RTL line by natural order'''
        self.assertEqual(pyfribidi.log2vis(U(b'\xd7\xa9\xd7\x9c\xd7\x95\xd7\x9d - hello'), ON),
                         U(b'hello - \xd7\x9d\xd7\x95\xd7\x9c\xd7\xa9'))

    def testNoReorderNonSpacingMarks(self):
        '''unicode: reorder non spacing marks'''
        self.assertEqual(pyfribidi.log2vis(U(b'\xd7\x97\xd6\xb7\xd7\x99\xd6\xb0\xd7\xa4\xd6\xb7\xd7\x90'), RTL, reordernsm=False),
                         U(b'\xd7\x90\xd6\xb7\xd7\xa4\xd6\xb0\xd7\x99\xd6\xb7\xd7\x97')
                         )

    def testReorderNonSpacingMarks(self):
        '''unicode: reorder non spacing marks'''
        self.assertEqual(pyfribidi.log2vis(U(b'\xd7\x97\xd6\xb7\xd7\x99\xd6\xb0\xd7\xa4\xd6\xb7\xd7\x90'), RTL),
                         U(b'\xd7\x90\xd7\xa4\xd6\xb7\xd7\x99\xd6\xb0\xd7\x97\xd6\xb7')
                         )

class UTF8Tests(unittest.TestCase):
    '''Same tests for utf8, used mainly on linux'''

    def testEmpty(self):
        '''utf8: empty string'''
        self.assertEqual(pyfribidi.log2vis(''), '')

    def testBigString(self):
        '''utf8: big string

        It does not make sense to order such big strings, this just
        checks that there are no size limits in pyfribidi.
        '''
        # About 2MB string
        big = ('א' * 1024) * 1024
        self.assertEqual(pyfribidi.log2vis(big), big)

    def testDefaultDirection(self):
        '''utf8: use RTL default'''
        self.assertEqual(pyfribidi.log2vis(b'hello - \xd7\xa9\xd7\x9c\xd7\x95\xd7\x9d'),
                         pyfribidi.log2vis(b'hello - \xd7\xa9\xd7\x9c\xd7\x95\xd7\x9d', RTL))

    def testAsRTL(self):
        '''utf8: reorder line as RTL'''
        self.assertEqual(pyfribidi.log2vis(b'hello - \xd7\xa9\xd7\x9c\xd7\x95\xd7\x9d', RTL),
                         b'\xd7\x9d\xd7\x95\xd7\x9c\xd7\xa9 - hello')

    def testAsLTR(self):
        '''utf8: reorder line as LTR'''
        self.assertEqual(pyfribidi.log2vis(b'hello - \xd7\xa9\xd7\x9c\xd7\x95\xd7\x9d', LTR),
                         b'hello - \xd7\x9d\xd7\x95\xd7\x9c\xd7\xa9')

    def testNaturalLTR(self):
        '''utf8: reorder LTR line by natural order'''
        self.assertEqual(pyfribidi.log2vis(b'hello - \xd7\xa9\xd7\x9c\xd7\x95\xd7\x9d', ON),
                         b'hello - \xd7\x9d\xd7\x95\xd7\x9c\xd7\xa9')

    def testNaturalRTL(self):
        '''utf8: reorder RTL line by natural order'''
        self.assertEqual(pyfribidi.log2vis(b'\xd7\xa9\xd7\x9c\xd7\x95\xd7\x9d - hello', ON),
                         b'hello - \xd7\x9d\xd7\x95\xd7\x9c\xd7\xa9')

    def testNoReorderNonSpacingMarks(self):
        '''utf8: reorder non spacing marks'''
        self.assertEqual(pyfribidi.log2vis(b'\xd7\x97\xd6\xb7\xd7\x99\xd6\xb0\xd7\xa4\xd6\xb7\xd7\x90', RTL, reordernsm=False),
                         b'\xd7\x90\xd6\xb7\xd7\xa4\xd6\xb0\xd7\x99\xd6\xb7\xd7\x97'
                         )

    def testReorderNonSpacingMarks(self):
        '''unicode: reorder non spacing marks'''
        self.assertEqual(pyfribidi.log2vis(b'\xd7\x97\xd6\xb7\xd7\x99\xd6\xb0\xd7\xa4\xd6\xb7\xd7\x90', RTL),
                         b'\xd7\x90\xd7\xa4\xd6\xb7\xd7\x99\xd6\xb0\xd7\x97\xd6\xb7'
                         )

class OtherEncodingsTests(unittest.TestCase):
    '''Minimal tests for other encodings'''

    def testIso8859_8NaturalRTL(self):
        '''other encodings: iso8859-8'''
        charset = 'iso8859-8'
        self.assertEqual(pyfribidi.log2vis(U(b'\xd7\xa9\xd7\x9c\xd7\x95\xd7\x9d - hello').encode(charset),
                                           encoding=charset),
                         U(b'hello - \xd7\x9d\xd7\x95\xd7\x9c\xd7\xa9').encode(charset))

    def testCp1255NaturalRTL(self):
        '''other encodings: cp1255'''
        charset = 'cp1255'
        self.assertEqual(pyfribidi.log2vis(U(b'\xd7\xa9\xd7\x9c\xd7\x95\xd7\x9d - hello').encode(charset),
                                           encoding=charset),
                         U(b'hello - \xd7\x9d\xd7\x95\xd7\x9c\xd7\xa9').encode(charset))

    def testUTF16NaturalRTL(self):
        '''other encodings: utf-16'''
        charset = 'utf-16'
        self.assertEqual(pyfribidi.log2vis(U(b'\xd7\xa9\xd7\x9c\xd7\x95\xd7\x9d - hello').encode(charset),
                                           encoding=charset),
                         U(b'hello - \xd7\x9d\xd7\x95\xd7\x9c\xd7\xa9').encode(charset))

class Crasher(unittest.TestCase):
    def test_glibc_free_invalid_next_size(self):
        # *** glibc detected *** /home/ralf/py27/bin/python2: free(): invalid next size (fast): 0x00000000011cff00 ***
        pyfribidi.log2vis(b'\\xf0\\x90\\x8e\\xa2\\xf0\\x90\\x8e\\xaf\\xf0\\x90\\x8e\\xb4\\xf0\\x90\\x8e\\xa1\\xf0\\x90\\x8f\\x83')

if __name__ == '__main__':
    suite = unittest.defaultTestLoader.loadTestsFromName(__name__)
    res = unittest.TextTestRunner().run(suite)
    sys.exit(not res.wasSuccessful())
