""" Spell Checker Lambda Function """

import json
import re

from spellchecker import SpellChecker  # [import-error]


def handler(event, context):  # pylint: disable=unused-argument
    """Lambda handler function"""
    spell = SpellChecker()

    # Print the event to the CloudWatch Logs
    print(f"Event: {event}")

    # Get the content to spell check from the input (event)
    content = event.get("content", "")

    cleaned_text = re.sub(r"[^a-zA-Z\s]", "", content)

    # Tokenize content into words
    words = cleaned_text.split()

    # Find misspelled words
    misspelled_words = spell.unknown(words)

    if misspelled_words:
        return {
            "statusCode": 400,
            "body": json.dumps(
                {"errors": list(misspelled_words), "message": "Spelling errors found."}
            ),
        }

    return {
        "statusCode": 200,
        "body": json.dumps({"message": "No spelling errors found."}),
    }
