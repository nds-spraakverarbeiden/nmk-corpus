# Lemmatizer v0.03 (Revised, with Curated Vocabulary)

This project provides a native dictionary and a revised morphological analyzer to:

- Generate **full-form dictionaries**
- Annotate **CoNLL files** with `NORM` and `LEMMA/POS` (no disambiguation)

Some implementation notes reflect historical development; file paths or components may have changed.

---

# Overview

- **Lemmatizer entry point:** `analyze.sh`
- **Vocabulary:** `dict/vocab_full.json`

---

# 1. Dictionary Bootstrapping

Raw full-form dictionaries are generated with:

```bash
make full_forms
````

These outputs require manual refinement.

## 1.1 Bootstrapping from Corpus Data

Because no dictionary initially existed, candidate paradigms were inferred from corpus annotations.

### Method

`scripts/filter-vocab.py` groups inflected forms under the most likely lemma:

1. Filter corpus files (`../morph/form/*.conll`) where **HMM POS** and **Morph POS** match.
2. Estimate lemma probability for each inflected form.
3. Rank lemma candidates by:

   * maximum lemma probability
   * mean lemma probability
4. Assign all forms to the highest-ranked lemma.
5. Define canonical forms per POS:

   * **VERB:** `Inf`, `Ind.Pl.Prs`
   * **NOUN:** `Nom.Sg`
   * **ADJ:** `Masc.Nom.Sg`

Output:

```
vocab.raw.json
```

### Cleaning and Consolidation

* `vocab.raw.json`

  * ~2422 lemmas
  * automatically generated and noisy

* `dict/vocab.json`

  * manually curated
  * ~2606 lemmas

Duplicate keys introduced during manual correction are merged using:

```
consolidate-vocab.py
```

---

## 1.2 Danneil Dictionary Integration

The Danneil Altmark dictionary was converted and integrated.

### Preparation

Duplicate the first column to align with internal format:

```bash
cat ../dicts/danneil-altmark/danneil.tsv \
 | perl -pe 's/^([^\t]\*\t)/\1\1/g;' \
 > danneil.tsv
```

Manual revisions included:

* phonological notation aligned with `dict/vocab.json`
* grammatical gender annotations

### Conversion

```bash
python3 scripts/tsvdict2json.py danneil.tsv -l 0 -n 0 -f 1 -p 2 \
 | jq . \
 > dict/danneil.json
```

The resulting JSON dictionary was manually refined.

---

# 2. Running the Lemmatizer

Compile with:

```bash
make
```

### Generated Components

| File                 | Description                                          |
| -------------------- | ---------------------------------------------------- |
| `roots.dic`          | stem list                                            |
| `lexemes.dic`        | lexeme list                                          |
| `word_formation.fst` | morphological analyzer generating lexemes from roots |
| `inflection.fst`     | inflectional analyzer                                |

### Word Formation

Compile and test:

```bash
make word_formation
make test_word_formation
```

Execution example:

```bash
../morph/scripts/fst4conll.py word_formation.a
```

Important behavior:

* Output pruning prioritizes lexeme entries over generated forms.
* Generated forms are marked with `?` if unattested.

### Inflection Transducers

Compiled with:

```bash
make update_inflection
```

Components include:

* `verbs.fst`
* `nouns.fst`
* `adj.fst`
* `pron.fst`
* `closed.fst`
* `inflection.fst`
* `desyllabify.fst`

Curated word lists are integrated from spreadsheet sources.

---

# 3. Morphological Modeling

## Ablaut Handling

Ablaut patterns in the corpus show substantial restructuring.
Instead of enforcing fixed verb classes, the analyzer **infers possible ablaut types**.

Each form may receive an ablaut tag:

```
.i  .ii  .iii  .iv  .v  .vi  .viia  .viib
```

These tags represent **possible interpretations** based on a manual assessment of all potential ablaut forms attested 10 times or more, not definitive classifications.
Subsequent processing can filter implausible analyses.

---

# 4. Generating Full-Form Dictionaries

Raw full-form dictionaries are generated via:

```bash
make full_forms
```

Pipeline:

1. Run `fst-parse` for each author with:

   * author-specific normalization (`$X2norm.a`)
   * `inflection.a`
2. Aggregate outputs into a TSV:

```
WORD   ALL_ANALYSES
```

3. `consolidate-full-forms.py`:

   * prunes analyses heuristically
   * infers `NORM`
   * performs syllabification

Note:

* Generated `NORM` values are **syllabified**, unlike entries in `dict/vocab.json`.
* Word formation tends to be **overgeneralized relative to inflection**.

---

# 5. Manual Curation of Full-Form Lists

The generated dictionaries were manually curated in `full_forms/`.

A fully curated example:

```
full_forms/bornemann-1810-gedichte.full.curated.tsv
```

This file served as a **reference corpus** for expanding dictionary coverage.

### Dictionary Expansion

The script:

```
dict2full_forms.py
```

generates:

* expanded JSON dictionaries
* full-form TSV dictionaries

Example:

```bash
python3 dict2full_forms.py dict/vocab.json dict/danneil.json \
  -tsv full_forms/bornemann-1810-gedichte.full.curated.tsv \
  -j -s '(bornemann|danneil)'
```

### Heuristic Filtering

Remaining raw outputs are filtered to isolate **OOV words** using:

```
filter-full-forms.py
```

Example:

```bash
python3 filter-full-forms.py \
 full_forms/bornemann-1816-gedichte.full.raw.tsv \
 full_forms/bornemann-1816-gedichte.from_dict.tsv \
 full_forms/bornemann-1810-gedichte.full.curated.tsv \
 > full_forms/bornemann-1816-gedichte.full.pre.tsv
```

### Manual Annotation Workflow

Final curation is performed using the full-form editor:

```
editor/full_form_editor.py
```

This enables manual correction while validating against corpus annotations.

---

# 6. Coverage Observations

The curated full-form dictionaries provide significantly better coverage than the base lexicon.

Example (Bornemann 1810):

| Source                       | Word Forms |
| ---------------------------- | ---------- |
| Curated full-form dictionary | ~3956      |
| `dict/vocab.json`            | ~918       |

Even after removing OCR errors and German loanwords, the curated dictionary still contains ~3270 entries.

---

# 7. Cascaded Lemmatizer

The final lemmatization pipeline is implemented in:

```
analyze.sh
```

Key characteristics:

* cascaded normalization and morphological analysis
* simplified normalization
* syllable boundaries removed during final processing

```
```
