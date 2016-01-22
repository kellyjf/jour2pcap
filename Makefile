
ifeq($(BORG),)
BORG:=jaguar-1
endif

TESTS := tm atg amp hd710
MCAPS = $(foreach m,$(TESTS),merge-$(m).pcap)
JCAPS = $(foreach m,$(TESTS),journal-$(m).pcap)
SCAPS = sharness-tm-tm.pcap $(foreach m,$(TESTS),sharness-$(m).pcap)
JTXTS = $(foreach m,$(TESTS),journal-$(m).txt)
JLOGS= $(foreach m,$(TESTS),journal-$(m).json)

all : $(MCAPS) $(JTXTS)

$(JLOGS) $(SCAPS):
	scp root@$(BORG):/var/log/jaguar/$@ .

$(JCAPS) : journal-%.pcap : journal-%.json
	./j2p journal-$*.json

$(JTXTS) : journal-%.txt: journal-%.json
	./j2t journal-$*.json

merge-%.pcap : journal-%.pcap sharness-%.pcap
	mergecap -w *-$*.pcap $<

clean:
	rm -f $(MCAPS) $(JCAPS) $(JTXTS)

reset: clean
	rm -f $(SCAPS) $(JLOGS)


