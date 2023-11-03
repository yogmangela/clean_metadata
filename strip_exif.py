python
import os
import boto3
from PIL import Image

s3 = boto3.client('s3')

def lambda_handler(event, context):
    for record in event['Records']:
        bucket = record['s3']['bucket']['bucket-a-tzxi7']
        key = record['s3']['object']['key']

        if key.endswith('.jpg'):
            # Download the image from Bucket A
            download_path = '/tmp/input.jpg'
            s3.download_file(bucket, key, download_path)
            
            # Process the image (remove EXIF metadata)
            with Image.open(download_path) as img:
                img_without_exif = Image.new(img.mode, img.size)
                img_without_exif.putdata(list(img.getdata()))
            
            # Upload the processed image to Bucket B with the same key
            upload_key = key
            upload_path = '/tmp/output.jpg'
            img_without_exif.save(upload_path, 'JPEG')
            s3.upload_file(upload_path, 'bucket-b-s791dg', upload_key)

            # Clean up temporary files
            os.remove(download_path)
            os.remove(upload_path)
