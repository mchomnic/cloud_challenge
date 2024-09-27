# Use an official Python runtime as a parent image
FROM public.ecr.aws/lambda/python:3.12

# Install spellchecker library
RUN pip install pyspellchecker

COPY spell_checker.py ${LAMBDA_TASK_ROOT}

CMD ["spell_checker.handler"]
