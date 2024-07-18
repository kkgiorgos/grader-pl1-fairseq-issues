all: fairseq_ocaml

fairseq_ocaml: fairseq.ml
	ocamlc -c fairseq.ml -o fairseq
	ocamlc fairseq.cmo -o fairseq_ocaml 

clean:
	rm -f fairseq_ocaml fairseq.cmo fairseq.cmi