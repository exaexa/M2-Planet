#! /bin/sh
## Copyright (C) 2017 Jeremiah Orians
## This file is part of M2-Planet.
##
## M2-Planet is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## M2-Planet is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with M2-Planet.  If not, see <http://www.gnu.org/licenses/>.

set -ex
# Build the test
./bin/M2-Planet --architecture knight-posix \
	-f test/common_knight/functions/file.c \
	-f test/common_knight/functions/malloc.c \
	-f functions/calloc.c \
	-f test/common_knight/functions/exit.c \
	-f functions/match.c \
	-f functions/in_set.c \
	-f functions/numerate_number.c \
	-f functions/file_print.c \
	-f functions/number_pack.c \
	-f functions/fixup.c \
	-f functions/string.c \
	-f cc.h \
	-f cc_reader.c \
	-f cc_strings.c \
	-f cc_types.c \
	-f cc_core.c \
	-f cc.c \
	--debug \
	-o test/test100/cc.M1 || exit 1

# Macro assemble with libc written in M1-Macro
M1 -f test/common_knight/knight_defs.M1 \
	-f test/common_knight/libc-core.M1 \
	-f test/test100/cc.M1 \
	--BigEndian \
	--architecture knight-posix \
	-o test/test100/cc.hex2 || exit 2

# Resolve all linkages
hex2 -f test/common_knight/ELF-knight.hex2 \
	-f test/test100/cc.hex2 \
	--BigEndian \
	--architecture knight-posix \
	--BaseAddress 0x00 \
	-o test/results/test100-knight-posix-binary --exec_enable || exit 3

# Ensure binary works if host machine supports test
if [ "$(get_machine ${GET_MACHINE_FLAGS})" = "knight*" ]
then
	# Verify that the resulting file works
	./test/results/test100-knight-posix-binary --architecture x86 \
		-f test/common_x86/functions/file.c \
		-f test/common_x86/functions/malloc.c \
		-f functions/calloc.c \
		-f test/common_x86/functions/exit.c \
		-f functions/match.c \
		-f functions/in_set.c \
		-f functions/numerate_number.c \
		-f functions/file_print.c \
		-f functions/number_pack.c \
		-f functions/fixup.c \
		-f functions/string.c \
		-f cc.h \
		-f cc_reader.c \
		-f cc_strings.c \
		-f cc_types.c \
		-f cc_core.c \
		-f cc.c \
		-o test/test100/proof || exit 4

	. ./sha256.sh
	out=$(sha256_check test/test100/proof.answer)
	[ "$out" = "test/test100/proof: OK" ] || exit 5
	[ ! -e bin/M2-Planet ] && mv test/results/test100-knight-posix-binary bin/M2-Planet
fi
exit 0
