import os
import subprocess
import boto3
import yaml
import time


def approximate_size(session, queue):
    attributes = session.get_queue_attributes(QueueUrl=queue,
                                              AttributeNames=['ApproximateNumberOfMessages',
                                                              'ApproximateNumberOfMessagesDelayed'])
    return int(attributes['Attributes']['ApproximateNumberOfMessages'])
    # return attributes.


def main():
    print('Application started')
    with open('/etc/access_key') as file:
        data = yaml.load(file, Loader=yaml.FullLoader)
        aws_access_key_id = data['access_key']['key_id']
        aws_secret_access_key = data['secret']
    with open('/etc/queue') as file:
        data = yaml.load(file, Loader=yaml.FullLoader)
        queue_url = data['QueueUrl']
    # Create SQS client
    my_session = boto3.session.Session(
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key,
        region_name='ru-central1')
    sqs = my_session.client('sqs', endpoint_url='https://message-queue.api.cloud.yandex.net')
    # Send message to SQS queue
    last_message_received = time.time()
    no_message_gap = 20  # 2 minutes

    while True:
        if approximate_size(sqs, queue_url) > 0:
            messages = sqs.receive_message(
                QueueUrl=queue_url,
                MaxNumberOfMessages=2,
                VisibilityTimeout=60,
                WaitTimeSeconds=10
            ).get('Messages')
            if messages is not None:
                if len(messages) != 0:
                    last_message_received = time.time()
                for msg in messages:
                    print('Received message: "{}"'.format(msg.get('Body')))
                    print('Working on message: "{}"...'.format(msg.get('Body')))
                    time.sleep(30)
                    sqs.delete_message(
                        QueueUrl=queue_url,
                        ReceiptHandle=msg.get('ReceiptHandle')
                    )
                    print('Successfully deleted message {} by receipt handle "{}"'.format(msg.get('Body'), msg.get('ReceiptHandle')))
        elif time.time() - last_message_received > no_message_gap:
            print('Application finished')
            os.system('systemctl poweroff')


if __name__ == "__main__":
    main()
