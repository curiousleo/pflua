TOP_SRCDIR:=..
include $(TOP_SRCDIR)/common.mk

all:

clean:

check:
	terra -l pf.types -e 'pf.types.selftest()'
	terra -l pf.utils -e 'pf.utils.selftest()'
	terra -l pf.libpcap -e 'pf.libpcap.selftest()'
	terra -l pf.bpf -e 'pf.bpf.selftest()'
	terra -l pf.parse -e 'pf.parse.selftest()'
	terra -l pf.expand -e 'pf.expand.selftest()'
	terra -l pf.optimize -e 'pf.optimize.selftest()'
	terra -l pf.anf -e 'pf.anf.selftest()'
	terra -l pf.ssa -e 'pf.ssa.selftest()'
	terra -l pf.backend -e 'pf.backend.selftest()'
	terra -l pf.match -e 'pf.match.selftest()'
	terra -l pf -e 'pf.selftest()'
