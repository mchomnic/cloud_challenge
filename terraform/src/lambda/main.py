import json
from spellchecker import SpellChecker

def lambda_handler(event, context):
    spell = SpellChecker()

    # Get the content to spell check from the input (event)
    content = event.get('content', '')

    # Tokenize content into words
    words = content.split()

    # Find misspelled words
    misspelled_words = spell.unknown(words)

    if misspelled_words:
        return {
            'statusCode': 400,
            'body': json.dumps({
                'errors': list(misspelled_words),
                'message': 'Spelling errors found.'
            })
        }

    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'No spelling errors found.'
        })
    }
