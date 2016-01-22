
ifeq ($(BORG),)
BORG := jaguar-1
endif

TESTS := tm atg amp hd710
FTESTS := full $(TESTS)

MCAPS = $(foreach m,$(FTESTS),merge-$(m).pcap)
JCAPS = $(foreach m,$(FTESTS),journal-$(m).pcap)
JTXTS = $(foreach m,$(FTESTS),journal-$(m).txt)
JLOGS= $(foreach m,$(FTESTS),journal-$(m).json)

SCAPS = $(foreach m,$(TESTS),sharness-$(m).pcap)


all : $(MCAPS) $(JTXTS)

$(JLOGS) $(SCAPS):
	scp root@$(BORG):/var/log/jaguar/$@ .

$(JCAPS) : journal-%.pcap : journal-%.json
	./j2p journal-$*.json

sharness-full.pcap : $(JCAPS)
	mergecap -w $@ $(JCAPS)

$(JTXTS) : journal-%.txt: journal-%.json
	./j2t journal-$*.json

merge-%.pcap : journal-%.pcap sharness-%.pcap
	mergecap -w $@ *-$*.pcap

clean:
	rm -f $(MCAPS) $(JCAPS) $(JTXTS) sharness-full.pcap

reset: clean
	rm -f $(SCAPS) $(JLOGS)


