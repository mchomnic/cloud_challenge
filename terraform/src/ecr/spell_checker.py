from spellchecker import SpellChecker
import json
import re

text = "Ths is an exmple of speling error."

def handler(event, context):
    spell = SpellChecker()

    # Print the event to the CloudWatch Logs
    print(f'Event: {event}')

    # Get the content to spell check from the input (event)
    content = event.get('content', '')

    cleaned_text = re.sub(r'[^a-zA-Z\s]', '', content)

    # Tokenize content into words
    words = cleaned_text.split()

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
