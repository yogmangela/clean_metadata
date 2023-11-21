import os
import boto3
from PIL import Image

s3 = boto3.client('s3')

def lambda_handler(event, context):
    for record in event['Records']:
        bucket_a = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        
        # Download image from S3 bucket A
        bucket_a = "your-bucket-a"
        download_path = '/tmp/{}'.format(key)
        s3.download_file(bucket_a, key, download_path)

        # Process image (remove EXIF metadata)
        processed_image = process_image(download_path)

        # Upload processed image to S3 bucket B
        bucket_b = 'your-bucket-b-name'
        upload_key = 'processed/{}'.format(key)
        s3.upload_file(processed_image, bucket_b, upload_key)

def process_image(image_path):
    img = Image.open(image_path)
    img_without_exif = Image.new(img.mode, img.size)
    img_without_exif.paste(img, (0, 0))
    
    processed_path = '/tmp/processed.jpg'
    img_without_exif.save(processed_path)
    
    return processed_path
