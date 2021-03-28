#!/bin/sh
#
# Generate the tokenizer extension data file from the parser header file.

# Go to project root directory.
cd "$(CDPATH= cd -- "$(dirname -- "$0")/../../" && pwd -P)"

infile="Zend/zend_language_parser.h"
outfile="ext/tokenizer/tokenizer_data.c"

if test ! -f "$infile"; then
  echo "$infile is missing." >&2
  echo "" >&2
  echo "Please, generate the PHP parser files by scripts/dev/genfiles" >&2
  echo "or by running the ./configure build step." >&2
  exit 1
fi

echo '/*
   +----------------------------------------------------------------------+
   | PHP Version 7                                                        |
   +----------------------------------------------------------------------+
   | Copyright (c) The PHP Group                                          |
   +----------------------------------------------------------------------+
   | This source file is subject to version 3.01 of the PHP license,      |
   | that is bundled with this package in the file LICENSE, and is        |
   | available through the world-wide-web at the following url:           |
   | http://www.php.net/license/3_01.txt                                  |
   | If you did not receive a copy of the PHP license and are unable to   |
   | obtain it through the world-wide-web, please send a note to          |
   | license@php.net so we can mail you a copy immediately.               |
   +----------------------------------------------------------------------+
   | Author: Johannes Schlueter <johannes@php.net>                        |
   +----------------------------------------------------------------------+
*/

/*
   DO NOT EDIT THIS FILE!
   This file is generated using tokenizer_data_gen.sh
*/

#include "php.h"
#include "zend.h"
#include <zend_language_parser.h>

' > $outfile

echo 'void tokenizer_register_constants(INIT_FUNC_ARGS) {' >> $outfile
awk '
	/^    T_(NOELSE|ERROR)/ { next }
	/^    T_/  { print "	REGISTER_LONG_CONSTANT(\"" $1 "\", " $1 ", CONST_CS | CONST_PERSISTENT);" }
' < $infile >> $outfile
echo '	REGISTER_LONG_CONSTANT("T_DOUBLE_COLON", T_PAAMAYIM_NEKUDOTAYIM, CONST_CS | CONST_PERSISTENT);' >> $outfile
echo '}' >> $outfile


echo '
char *get_token_type_name(int token_type)
{
	switch (token_type) {
' >> $outfile

awk '
	/^    T_PAAMAYIM_NEKUDOTAYIM/ {
		print "		case T_PAAMAYIM_NEKUDOTAYIM: return \"T_DOUBLE_COLON\";"
		next
	}
	/^    T_(NOELSE|ERROR)/ { next }
	/^    T_/ {
		print "		case " $1 ": return \"" $1 "\";"
	}
' < $infile >> $outfile

echo '
	}
	return "UNKNOWN";
}
' >> $outfile

echo "Wrote $outfile"
