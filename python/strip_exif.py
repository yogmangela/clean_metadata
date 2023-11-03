import boto3
import io
from PIL import Image

s3 = boto3.client('s3')

def lambda_handler(event, context):
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']

        # Download the image from bucket-A
        image_data = s3.get_object(Bucket='bucket-a-3xhbq', Key='img')['Body'].read()
        # image_data = s3.get_object(Bucket=bucket, Key=key)['Body'].read()

        # Process the image (remove EXIF data)
        image = Image.open(io.BytesIO(image_data))
        image = image.convert('RGB')
        image_data = io.BytesIO()
        image.save(image_data, 'JPEG')

        # Upload the processed image to bucket-B
        s3.put_object(Bucket='bucket-b-7c58h2', Key='img', Body=image_data.getvalue())
