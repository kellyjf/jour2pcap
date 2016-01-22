
TESTS := atg amp hd710
PCAPS = $(foreach m,$(TESTS),merge-$(m).pcap)
JCAPS = $(foreach m,$(TESTS),journal-$(m).pcap)
SCAPS = $(foreach m,$(TESTS),sharness-$(m).pcap)
JTXT = $(foreach m,$(TESTS),journal-$(m).txt)

all : $(PCAPS)

test:
	echo $(PCAPS)


$(JTXT) $(SCAPS):
	scp root@jaguar-1:/var/log/jaguar/$@ .



$(JCAPS) : journal-%.pcap : journal-%.txt
	./j2p journal-$*.txt

merge-%.pcap : journal-%.pcap sharness-%.pcap
	mergecap -w $@ $<

clean:
	rm -f $(PCAPS) $(JCAPS)

reset: clean
	rm -f $(SCAPS) $(JTXT)


