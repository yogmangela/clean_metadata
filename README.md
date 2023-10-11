# clean_metadata
Creates a system that retrieves .jpg files when they are uploaded to the S3 bucket A, removes any exif metadata,  and save them to another S3 bucket B.

#### Pre-requesite
- Python 🐍  🐍
[![Python 3.11](https://img.shields.io/badge/python-3.11-green.svg)](https://www.python.org/downloads/release/python-3110/) 
- Terraform v1.6.0 
- AWS user:
    This repository assumes you have already setup default aws profile. check [aws configure](https://wellarchitectedlabs.com/common/documentation/aws_credentials/)
- clone this repository and use branch [origin/add_lambda](https://github.com/yogmangela/clean_metadata.git) to deploy resources.

- Aliases saves time (linux)
```console
alias ti="terraform init"
alias tp="terraform plan"
alias tv="terraform validate"
alias tf="terraform fmt"
alias ta="terraform apply"
```

## To Create resources
- run ```ta```  (```terraform init```)
- run ```tp```  (```terraform plan```)
- run ```tv```  (```terraform validate```)
- run ```tf```  (```terraform fmt```) Terraform canonical formating
- run ```ta```  (```terraform apply```) 

- Use terraform output to change the `bucket-b-XXXXX` under `/python/strip_exif.py` on line:23.
- and in the `lambda.tf` change both buckets `bucket-a-XXXXX` and `bucket-b-XXXXX`


## Improvements

- to make it secure add Lambda to [VPC/Subnets](https://github.com/terraform-aws-modules/terraform-aws-lambda/blob/v6.0.1/examples/with-vpc/main.tf)

- Add Security Groups for hardening  

- automating bucketname ingestion

## Outcome:

- currently the 
# Yogesh Mangela (Yogs)




