# Lemmatizer v.0.03, revised and with curated vocabulary

We provide an native dictionary and a revised morphological analyzer to generate full-form dictionaries or to annotate CoNLL files with NORM and LEMMA/POS (no disambiguation).

## TL/DR

- build with `make`. Note that you might need quite a bit of RAM.
- lemmatizer: `analyze.sh`
- manually curated author vocabularies: [`full_form/`](full_form/)
- overall vocabulary: `dict/vocab_full.json`

## refactored lemmatizer

cascaded lemmatizer, call in interactive mode with 

	$> bash -e analyze.sh

Alternatively, you can also feed one-line per word-annotated files as arguments

	$> bash -e analyze.sh test.txt

Note that it will skip any line starting with `#`. This can also process TSV formats, but then, processes the first column only, keeps all existing annotations intact (for the first line of results, all others being replaced by `*`), and appends the analysis.

> Internally, `analyze.sh` calls `fst-wrapper.py` with strict minimization, norm inference, timeouts and using `analyze.sh.cache.json` as cache. When processing a specific (family of) document(s), this cache will contain the document vocabulary in a `vocab.json`-compliant format. This can be used for manual vocabulary corrections.

For testing a default configuration, run `make test`. Make sure to manually delete `analyze.sh.cache.json` beforehand.

For a detailed description of the components and the steps taken to construct them, see [concept-and-development.md](concept-and-development.md).