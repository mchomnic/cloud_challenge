# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /usr/src/app

# Install spellchecker library
RUN pip install pyspellchecker

# Copy the spellchecker script to the container
COPY spellcheck.py .

# Command to run the spellcheck function
CMD ["python", "./spellcheck.py"]
