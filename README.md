# Automated Department File Upload & Organization System

**A serverless, zero-touch solution for intelligent file routing to a central Windows FSx share.**

## Objective

Implement a simple, automated system that allows departments (**Corporate**, **HR**, **Technology**, and future groups) to upload files into dedicated locations and have them **instantly and intelligently organized** into the correct folders on the central Windows shared file system — with **zero manual effort**.

## Solution Overview

Each department gets its own dedicated **S3 upload bucket**:

- `corporate-upload-bucket`
- `hr-upload-bucket`
- `technology-upload-bucket`
- *(easily expandable to new departments)*

When a user uploads **any file** to their department’s bucket, the system automatically:

1. Identifies the department from the bucket name
2. Detects the file type (by extension)
3. Copies the file to the appropriate subfolder on the central **FSx for Windows File Server**
4. Sends a real-time confirmation email to `elucas@ocsheriff.gov`

## Resulting Folder Structure (UNC Path)


One reminder, I am not including the lambda zip, try to do that yourself by following this 

1. Create a clean folder
mkdir lambda_package && cd lambda_package

# 2. Install dependencies
pip install -r ../requirements.txt -t .

# 3. Copy your code
cp ../lambda_function.py .

# 4. Zip it
zip -r ../lambda_function.zip .
