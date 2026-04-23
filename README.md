Objective Implement a simple, automated system that allows departments (Corporate, HR, Technology, and future groups) to upload files into dedicated locations and have them instantly and intelligently organized into the correct folders on the central Windows shared file system — with zero manual effort.
Solution Overview
•	Each department receives its own dedicated S3 upload bucket:
o	corporate-upload-bucket
o	hr-upload-bucket
o	technology-upload-bucket
•	When a user uploads any file to their department’s bucket, the system automatically:
1.	Identifies the department (by bucket)
2.	Detects the file type (extension)
3.	Copies the file to the appropriate folder on the central FSx for Windows shared drive
•	Real-time email notifications are sent to elucas@ocsheriff.gov confirming successful routing.
Resulting Folder Structure on Shared Drive (UNC Path)
text
\\fsx-share\
├── corporate/
│   ├── documents/
│   ├── txt/
│   └── csv/
├── hr/
│   ├── spreadsheets/
│   └── txt/
└── technology/
    ├── archives/
    └── images/
Key Benefits
•	Dramatically reduces time wasted on manual file moving and organizing
•	Ensures consistent, professional folder structure across departments
•	Extremely easy for end users — “just drop the file in your bucket”
•	Highly scalable — new departments can be added in minutes
•	Improves compliance, searchability, and audit readiness
•	Fully secure, serverless, and Windows-native (standard UNC/SMB shares)
Technology & Delivery
•	Built entirely in Terraform (Infrastructure as Code) for reliability and repeatability
•	Uses native AWS services: S3, Lambda, FSx for Windows File Server, SSM Parameter Store, and SNS
•	Low operational overhead — fully automated once deployed
Estimated Cost $60 – $85 per month (including FSx storage, S3, Lambda, and notifications). First-year total: approximately $800 – $1,100.
Recommended Rollout A clean 4-week implementation:
•	Week 1: Preparation & FSx setup
•	Week 2: Build, test, and security review
•	Week 3: Pilot with departments
•	Week 4: Full go-live with user instructions
This solution delivers immediate productivity gains and long-term organization improvements with minimal ongoing maintenance.
Recommendation Approve proceeding with implementation. It is a high-ROI, low-risk project that modernizes file workflows across the organization.

One reminder, I am not including the lambda zip, try to do that yourself by following this 

1. Create a clean folder
mkdir lambda_package && cd lambda_package

# 2. Install dependencies
pip install -r ../requirements.txt -t .

# 3. Copy your code
cp ../lambda_function.py .

# 4. Zip it
zip -r ../lambda_function.zip .
