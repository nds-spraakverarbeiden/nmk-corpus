# Building a Corpus of North Markian and Central Pomeranian (NMK Corpus)

> **DO NOT EDIT DIRECTLY**
> - This is the public release repository for the NMK corpus. For internal development, please checkout [our private repository](https://github.com/acoli-repo/nmk-corpus) and run `make update_release` *in that repository* to update any data here.
> - Note that not all build scripts have been migrated yet.
> - If you like to contribute, or want to get access to the original build scripts, please get in touch with [@chiarcos](https://github.com/chiarcos) and/or the [Chair of Applied Computational Linguistics at the University of Augsburg, Germany](https://www.uni-augsburg.de/en/fakultaet/philhist/professuren/Applied-Computational-Linguistics/).


This repository provides a corpus of North Markian and Central Pomeranian (German _Nordmärkisch-Mittelpommersches Korpus_, NMK), consisting of copyright-free literary works to represent the primary regions and varieties of the dialect.

North Markian is a dialect of Low German spoken in the federal states of Sachsen-Anhalt, Brandenburg and Mecklenburg-Vorpommern in Germany. For modern Mecklenburg-Vorpommern and the historical region of Hither Pomerania in modern Poland, the dialect is referred to as _Central Pomeranian_, but differences between North Markian proper and Central Pomeranian are marginal. In modern Poland, the dialect is extict, in Germany, it is severely threatened.

Since July 2024, the Low German language [is protected by state law](https://bravors.brandenburg.de/gesetze/bbgndg) in the federal state of Brandenburg, but political decisions and educational resources to protect and support the language should be made in accordance with an understanding of the characteristics of the language that is to be protected. Unfortunately, North Markian is very poorly documented and scientifically underexplored so that these characteristics are largely unknown. This corpus is being developed with the intent to address that gap and to provide a basis for the study of North Markian with modern methods of corpus linguistics, digital lexicography and computational linguistics.

## Terms and conditions

The **corpus** is released as open source under the [Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA)][LICENSE] license. You are free to

* **Share** — copy and redistribute the material in any medium or format for any purpose, even commercially.
* **Adapt** — remix, transform, and build upon the material for any purpose, even commercially.

Under the following terms:

* **Attribution** — You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
* **ShareAlike** — If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.

If you use any data or code from this repository, esp. in an academic context, please cite the following paper

> Christian Chiarcos (2026), Towards the Morphological Annotation of North Markian (Low German), In Proceedings of the Fifteenth biennial Language Resources and Evaluation Conference (LREC-2026), Palma, Mallorca, Spain, May 13-15, 2026.

This repository also contains software, in particular, tools for the morphological analysis of North Markian in particular and Low German in general. The **code** contained in this repository is published as open source under the Apache License, Version 2.0, January 2004, http://www.apache.org/licenses/.

**Disclaimer**:
No warrantees whatsoever. All data provided here was created with automated methods, incl. automated OCR, automated POS annotation and (under development) automated lemmatization.


## Contents of this repository

- [`pdf/`](pdf) gzipped PDFs containing the source texts (scanned, content pages only)
- [`txt/`](txt) Transkribus OCR, plain text (no OCR post-correction)
- [`upos/`](upos) automated annotation for universal parts of speech in four columns, `FORM`, `UPOS` (predicted part of speech) and two auxiliary columns (see UPOS annotation below)
- [`lemmatizer/`](lemmatizer) Lemmatizer v0.3


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

## NMK Lemmatizer v0.3

Finite-state morphology and manually curated full form dictionaries for the analysis of North Markian / Central Pomeranian authors from the 19th c.

- see [`Readme`](lemmatizer/Readme.md) for how to compile and run
- including a [command-line editor](lemmatizer/editor) for manual curation of analyzed forms 
- including manually curated [full-form lists](lemmatizer/full_forms)

Note that Lemmatizer v0.3 does not perform disambiguation. This is to be accomplished with transfer learning using data from related language varieties.

> The earlier versions v0.1 and v0.2 have been developed for and used in an iterative bootstrapping and refinement cycle as described in the accompanying paper, but have not been properly released.



## TODO

- migrate `upos/` scripts
- document `editor/` and refinement cycles
- add documentation on North Markian and Low German
