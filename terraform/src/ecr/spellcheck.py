import sys
from spellchecker import SpellChecker

# Sample text to check
text = "Ths is an exmple of speling error."

spell = SpellChecker()
misspelled = spell.unknown(text.split())

if misspelled:
    print("Misspelled words:", ", ".join(misspelled))
else:
    print("No spelling errors found.")
