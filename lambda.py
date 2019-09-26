"""
Checks url and store response time and status code
"""

import boto3
import logging
from botocore.vendored import requests

client = boto3.client('cloudwatch')
logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    logger.info('Event:' + str(event))

    response = requests.get(event['url'])

    logger.info("Putting HTTP Status")
    got_valid_status_code = str(response.status_code) in event['valid_status_codes'].split(",")

    client.put_metric_data(
      Namespace='HTTP Checks',
      MetricData=[
          {
              'MetricName': 'WebStatus',
              'Dimensions': [
                  {
                      'Name': 'URL',
                      'Value': event["url"],
                  }
              ],
              'Value': 0 if got_valid_status_code else 1,
          }
      ]
    )

    logger.info("Putting HTTP response time")
    client.put_metric_data(
      Namespace='HTTP Checks',
      MetricData=[
          {
              'MetricName': 'WebResponseTime',
              'Dimensions': [
                  {
                      'Name': 'URL',
                      'Value': event["url"],
                  }
              ],
              'Value': response.elapsed.total_seconds(),
          }
      ]
    )
