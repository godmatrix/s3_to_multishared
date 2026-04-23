import json
import boto3
import urllib.parse
import os

s3  = boto3.client('s3')
sns = boto3.client('sns')

SNS_TOPIC_ARN = os.environ['SNS_TOPIC_ARN']

# Extension → Shared Folder (prefix) mapping
# Add any extension you want here
EXTENSION_MAP = {
    "txt": "shared/txt/",
    "csv": "shared/csv/",
    # "pdf": "shared/pdf/",
    # "jpg": "shared/images/",
}

def lambda_handler(event, context):
    for record in event.get('Records', []):
        bucket = record['s3']['bucket']['name']
        key    = urllib.parse.unquote_plus(record['s3']['object']['key'])
        
        # Extract extension
        ext = key.split('.')[-1].lower() if '.' in key else ""
        
        if ext in EXTENSION_MAP:
            prefix   = EXTENSION_MAP[ext]
            filename = key.split('/')[-1]
            new_key  = prefix + filename
            
            # Copy to the designated shared folder
            s3.copy_object(
                Bucket=bucket,
                CopySource={'Bucket': bucket, 'Key': key},
                Key=new_key
            )
            
            # Optional: delete original (uncomment for "move" instead of copy)
            # s3.delete_object(Bucket=bucket, Key=key)
            
            message = f"✅ File routed\nOriginal: {key}\nExtension: .{ext}\nNew location: {new_key}"
            sns.publish(TopicArn=SNS_TOPIC_ARN, Message=message, Subject="File Router Notification")
            
            print(message)
        else:
            # No mapping → still notify (optional)
            sns.publish(
                TopicArn=SNS_TOPIC_ARN,
                Message=f"⚠️ File received with unknown extension: {key}"
            )
    
    return {"statusCode": 200}