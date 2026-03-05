# Building a Corpus of North Markian and Central Pomeranian (NMK Corpus)

> **DO NOT EDIT DIRECTLY**
> - This is the public release repository for the NMK corpus. For internal development, please checkout [our private repository](https://github.com/acoli-repo/nmk-corpus) and run `make update_release` *in that repository* to update any data here.
> - Note that not all build scripts have been migrated yet.
> - If you like to contribute, or want to get access to the original build scripts, please get in touch with [@chiarcos](https://github.com/chiarcos) and/or the [Chair of Applied Computational Linguistics at the University of Augsburg, Germany](https://www.uni-augsburg.de/en/fakultaet/philhist/professuren/Applied-Computational-Linguistics/).


**Content**:

- [`pdf/`](pdf) gzipped PDFs containing the source texts (scanned, content pages only)
- [`txt/`](txt) Transkribus OCR, plain text (no OCR post-correction)
- [`upos/`](upos) automated annotation for universal parts of speech in four columns, `FORM`, `UPOS` (predicted part of speech) and two auxiliary columns (see UPOS annotation below)
- [`lemmatizer/`](lemmatizer) lemmatizer v0.03

## NMK Lemmatizer v0.03

Finite-state morphology and manually curated full form dictionaries for the analysis of North Markian / Central Pomeranian authors from the 19th c.

- see [`Readme`](lemmatizer/Readme.md) for how to compile and run
- including a [command-line editor](lemmatizer/editor) for manual curation of analyzed forms 
- including manually curated [full-form lists](lemmatizer/full_forms)

Note that lemmatizer v0.03 does not perform disambiguation. This is to be accomplished with transfer learning using data from related language varieties.

> The earlier versions v0.01 and v0.02 have been developed for and used in an iterative bootstrapping and refinement cycle as described in the accompanying paper, but have not been properly released.

## Corpus data and UPOS annotation

As the lemmatizer does not support automated disambiguation for morphological analyses yet, we only provide corpus data with POS tagging. This is the first digital corpus of North Markian text we are aware of and one of the first freely available corpus of Low German literature. However, this is still work in progress as it suffers from a number of drawbacks:

- The text is automatically OCRed, without manual post-editing
- The text contains doublettes: As for Bornemann's texts, many poems from his 1810/16 book may also occur in the 1868 re-edition. However, we include both, as the older texts belong to the oldest attestations of North Markian, and the younger ones have been substantially modernized (and, in the eyes of speakers, sanitized) two generations after. As for Dörr's text, the original publication contained duplicate and re-ordered pages, so that some pages are actually included up to 7 times. Also, as sentence boundaries are inferred across page breaks, this leads to incorrect sentences.
- the text contains passages in High German, Yiddish, French, Mecklenburgian (another, more remotely related Low German dialect), Missingsch (a historical regiolect blending aspects of Low German and High/Central German) which are not identified as such

At the moment, this data can be of value for the study of morphology and lexis, but not for the study of syntax. In its very nature, it is at the stage of auxiliary created to support the development of a lemmatizer, i.e., for pre-filtering the word forms in order to develop morphological analysis components for verbal, nominal, adjectival and pronominal inflectional and derivational morphology. In subsequent research, we plan to consolidate the corpus and provide a proper release.

[`upos/`](upos) provides automated annotation for universal parts of speech in four columns, `FORM`, `UPOS` (predicted part of speech), `UPOS-HMM` (HMM prediction), `UPOS-DICT` (parts of speech according to dictionary lookup):

- `FORM`
- `UPOS` universal part of speech, based on rule-based integration of HMM- and dictionary annotations
	1. use `UPOS-HMM` tag if among `UPOS-DICT` tags; else 
	2. use `UPOS-DICT` tag if unambiguous; else
	3. use `UPOS-HMM` tag with question mark
- `UPOS-HMM` automated UPOS annotation with [Hammy](https://github.com/acoli-repo/hammy/), i.e. either
	1. (*direct mode*) initially performed by combining transition probabilities from UD corpora (see [Readme](upos/Readme.md) for details) and emission probabilities from a heuristically bootstrapped dictionaries and statistical OOV heuristics, or
	2. (*retraining mode*): annotated with Hammy HMM trained over the data resulting from direct annotation

	During compilation, we automatically identify the best-performing parameter configuration against a manually annotated sample. The best-performing configuration is applied, see [Readme](upos/Readme.md) for evaluation scores and the parameters of the best-performing configuration.

- `UPOS-DICT` lookup-based UPOS annotations against a heuristically compiled POS dictionary, no disambiguation.

## TODO

- migrate `upos/` scripts
- document `editor/` and refinement cycles
- add documentation on North Markian and Low German
