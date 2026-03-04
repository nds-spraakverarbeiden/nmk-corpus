# Corpus of North Markian and Central Pomeranian (NMK Corpus)

> **DO NOT EDIT DIRECTLY**
> - This is the public release repository for the NMK corpus. For internal development, please checkout [our private repository](https://github.com/acoli-repo/nmk-corpus) and run `make update_release` *in that repository* to update any data here.
> - Note that not all build scripts have been migrated yet.
> - If you like to contribute, or want to get access to the original build scripts, please get in touch with [@chiarcos](https://github.com/chiarcos) and/or the [Chair of Applied Computational Linguistics at the University of Augsburg, Germany](https://www.uni-augsburg.de/en/fakultaet/philhist/professuren/Applied-Computational-Linguistics/).


**Content**:

- [`pdf/`](pdf) gzipped PDFs containing the source texts (scanned, content pages only)
- [`txt/`](txt) Transkribus OCR, plain text (no OCR post-correction)
- [`upos/`](upos) automated annotation for universal parts of speech in four columns, `FORM`, `UPOS` (predicted part of speech) and two auxiliary columns (see UPOS annotation below)

## UPOS annotation

[`upos/`](upos) provides automated annotation for universal parts of speech in four columns, `FORM`, `UPOS` (predicted part of speech), `UPOS-HMM` (HMM prediction), `UPOS-DICT` (parts of speech according to dictionary lookup):

- `FORM`
- `UPOS` universal part of speech, based on rule-based integration of HMM- and dictionary annotations
	1. use `UPOS-HMM` tag if among `UPOS-DICT` tags; else 
	2. use `UPOS-DICT` tag if unambiguous; else
	3. use `UPOS-HMM` tag with question mark
- `UPOS-HMM` automated UPOS annotation with [Hammy](https://github.com/acoli-repo/hammy/), i.e. either
	1. (*direct mode*) initially performed by combining transition probabilities from UD corpora (see [Readme](upos/Readme.md) for details) and emission probabilities from a heuristically bootstrapped dictionaries and statistical OOV heuristics, or
	2. (*retraining mode*): annotated with Hammy HMM trained over the data resulting from direct annotation

	During compilation, we identify the best-performing parameter configuration against a manually annotated sample. The best-performing configuration is applied, see [Readme](upos/Readme.md) for evaluation scores and the parameters of the best-performing configuration.

- `UPOS-DICT` lookup-based UPOS annotations against a heuristically compiled POS dictionary, no disambiguation.

## TODO

- migrate `upos/` scripts
