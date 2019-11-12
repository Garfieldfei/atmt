cat baseline/raw_data/train.de | perl moses_scripts/normalize-punctuation.perl -l de | perl moses_scripts/tokenizer.perl -l de -a -q > baseline/preprocessed_data/train.de.p

cat baseline/raw_data/train.en | perl moses_scripts/normalize-punctuation.perl -l en | perl moses_scripts/tokenizer.perl -l en -a -q > baseline/preprocessed_data/train.en.p

perl moses_scripts/train-truecaser.perl --model baseline/preprocessed_data/tm.de --corpus baseline/preprocessed_data/train.de.p

perl moses_scripts/train-truecaser.perl --model baseline/preprocessed_data/tm.en --corpus baseline/preprocessed_data/train.en.p

cat baseline/preprocessed_data/train.de.p | perl moses_scripts/truecase.perl --model baseline/preprocessed_data/tm.de > baseline/preprocessed_data/train.de 

cat baseline/preprocessed_data/train.en.p | perl moses_scripts/truecase.perl --model baseline/preprocessed_data/tm.en > baseline/preprocessed_data/train.en

cat baseline/raw_data/valid.de | perl moses_scripts/normalize-punctuation.perl -l de | perl moses_scripts/tokenizer.perl -l de -a -q | perl moses_scripts/truecase.perl --model baseline/preprocessed_data/tm.de > baseline/preprocessed_data/valid.de

cat baseline/raw_data/valid.en | perl moses_scripts/normalize-punctuation.perl -l en | perl moses_scripts/tokenizer.perl -l en -a -q | perl moses_scripts/truecase.perl --model baseline/preprocessed_data/tm.en > baseline/preprocessed_data/valid.en

cat baseline/raw_data/test.de | perl moses_scripts/normalize-punctuation.perl -l de | perl moses_scripts/tokenizer.perl -l de -a -q | perl moses_scripts/truecase.perl --model baseline/preprocessed_data/tm.de > baseline/preprocessed_data/test.de

cat baseline/raw_data/test.en | perl moses_scripts/normalize-punctuation.perl -l en | perl moses_scripts/tokenizer.perl -l en -a -q | perl moses_scripts/truecase.perl --model baseline/preprocessed_data/tm.en > baseline/preprocessed_data/test.en

cat baseline/raw_data/tiny_train.de | perl moses_scripts/normalize-punctuation.perl -l de | perl moses_scripts/tokenizer.perl -l de -a -q | perl moses_scripts/truecase.perl --model baseline/preprocessed_data/tm.de > baseline/preprocessed_data/tiny_train.de

cat baseline/raw_data/tiny_train.en | perl moses_scripts/normalize-punctuation.perl -l en | perl moses_scripts/tokenizer.perl -l en -a -q | perl moses_scripts/truecase.perl --model baseline/preprocessed_data/tm.en > baseline/preprocessed_data/tiny_train.en

cat baseline/raw_data/corpus.en | perl moses_scripts/normalize-punctuation.perl -l en | perl moses_scripts/tokenizer.perl -l en -a -q | perl moses_scripts/truecase.perl --model baseline/preprocessed_data/tm.en > baseline/preprocessed_data/corpus.en

rm baseline/preprocessed_data/train.de.p
rm baseline/preprocessed_data/train.en.p

cat baseline/preprocessed_data/train.en baseline/preprocessed_data/train.de | subword-nmt learn-bpe -s 3500 -o code.bpe

subword-nmt apply-bpe -c code.bpe < baseline/preprocessed_data/train.en | subword-nmt get-vocab > baseline/subword/vocab.en
subword-nmt apply-bpe -c code.bpe < baseline/preprocessed_data/train.de | subword-nmt get-vocab > baseline/subword/vocab.de

subword-nmt apply-bpe -c code.bpe --vocabulary baseline/subword/vocab.en < baseline/preprocessed_data/train.en > baseline/subword/train_bpe.en
subword-nmt apply-bpe -c code.bpe --vocabulary baseline/subword/vocab.de < baseline/preprocessed_data/train.de > baseline/subword/train_bpe.de

subword-nmt apply-bpe -c code.bpe --vocabulary baseline/subword/vocab.en < baseline/preprocessed_data/test.en > baseline/subword/test_bpe.en
subword-nmt apply-bpe -c code.bpe --vocabulary baseline/subword/vocab.de < baseline/preprocessed_data/test.de > baseline/subword/test_bpe.de

subword-nmt apply-bpe -c code.bpe --vocabulary baseline/subword/vocab.en < baseline/preprocessed_data/valid.en > baseline/subword/valid_bpe.en
subword-nmt apply-bpe -c code.bpe --vocabulary baseline/subword/vocab.de < baseline/preprocessed_data/valid.de > baseline/subword/valid_bpe.de

subword-nmt apply-bpe -c code.bpe --vocabulary baseline/subword/vocab.en < baseline/preprocessed_data/tiny_train.en > baseline/subword/tiny_train_bpe.en
subword-nmt apply-bpe -c code.bpe --vocabulary baseline/subword/vocab.de < baseline/preprocessed_data/tiny_train.de > baseline/subword/tiny_train_bpe.de

subword-nmt apply-bpe -c code.bpe --vocabulary baseline/subword/vocab.en < baseline/preprocessed_data/corpus.en > baseline/subword/corpus_bpe.en

rm code.bpe

cat baseline/subword/train_bpe.de baseline/subword/corpus_bpe.en > baseline/subword/train.de
cat baseline/subword/train_bpe.en baseline/subword/corpus_bpe.en > baseline/subword/train.en
cat baseline/subword/corpus_bpe.en baseline/subword/train_bpe.de baseline/subword/train_bpe.en > baseline/subword/train.den

python preprocess.py --target-lang en --source-lang de --mono-lang den --dest-dir baseline/prepared_subword/ --train-prefix baseline/subword/train --valid-prefix baseline/subword/valid_bpe --test-prefix baseline/subword/test_bpe --tiny-train-prefix baseline/subword/tiny_train_bpe --threshold-src 1 --threshold-tgt 1 --num-words-src 6000 --num-words-tgt 6000
