""" Visitor counter Lambda function
    Function to increment a visitor counter in a DynamoDB table
"""

import json
import os

import boto3

from botocore.exceptions import ClientError

# Initialize the DynamoDB client
dynamodb = boto3.resource('dynamodb')



# DynamoDB table name
TABLE_NAME = os.getenv("TABLE_NAME")

def lambda_handler(event, context):     # pylint: disable=unused-argument
    """ Main function, lambda handler """

    # Define the primary key of the counter table
    primary_key = {'id': 'counter'}

    # Connect to the DynamoDB table
    table = dynamodb.Table(TABLE_NAME)

    try:
        # Increment the visitor count using UpdateItem with an atomic update
        response = table.update_item(
            Key=primary_key,
            UpdateExpression="SET visitor_count = if_not_exists(visitor_count, :start) + :inc",
            ExpressionAttributeValues={
                ':start': 0,  # Start count from 0 if it doesn't exist
                ':inc': 1     # Increment value
            },
            ReturnValues="UPDATED_NEW"
        )

        # Retrieve the updated visitor count
        new_count = response['Attributes']['visitor_count']
        print(f"Visitor count: {new_count}")

        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'GET',
            },
            'body': json.dumps({'visitor_count': int(new_count)}, )
        }

    except ClientError as e:
        # Handle errors during the DynamoDB operation
        print(e.response['Error']['Message'])
        return {
            'statusCode': 500,
            'body': json.dumps('Error updating visitor count')
        }
