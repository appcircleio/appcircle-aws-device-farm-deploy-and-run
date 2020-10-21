# AWS Device Farm Deploy and Run

Deploy a file to AWS Device Farm and run tests.

Releated Documentation
- https://docs.aws.amazon.com/cli/latest/reference/devicefarm/create-upload.html
- https://docs.aws.amazon.com/cli/latest/reference/devicefarm/schedule-run.html

Required Input Variables
- `$AWS_ACCESS_KEY_ID`: Amazon S3 access key id
- `$AWS_SECRET_ACCESS_KEY`: Amazon S3 secret access key (Visit [AWS access keys documentation](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys) for details)
- `$AWS_PROJECT_ARN`: The ARN of the project for deploy and run
- `$AWS_DEVICE_POOL_ARN`: The ARN of the device pool for the run
- `$AWS_SCHEDULE_RUN_NAME_PREFIX`: The name prefix for the run to be scheduled
- `$AWS_SCHEDULE_TEST_TYPE`: The type of the test for the run.
- `$AWS_UPLOAD_TIMEOUT`: Time out duration (seconds) for the test file upload. The step is skipped if the time out is reached.
- `$AWS_TEST_TIMEOUT`: Time out duration (seconds) for the AWS Device Farm run. The step is skipped if this duration is reached, but the test execution continues in AWS Device Farm.
- `$AWS_APP_ARN`: The ARN of the application package to run tests against, created with CreateUpload. If you don't set this parameter, the subsequent App Upload File Name, App Upload Type and App Upload File Path parameters are required.
- `$AWS_APP_UPLOAD_FILE_NAME`: The file to be uploaded. The name should not contain any forward slashes (/ ). If you are uploading an iOS app, the file must have an .ipa extension. If you are uploading an Android app, the file must have an .apk extension
- `$AWS_APP_UPLOAD_TYPE`: The upload type of the file.
- `$AWS_APP_UPLOAD_FILE_PATH`: The file path for the app upload.
- `$AWS_TEST_ARN`: The ARN of the uploaded test to be run. If you don't set this parameter, the subsequent AWS Test Upload File Name, AWS Test Upload Type and AWS App Upload File Path parameters are required.
- `$AWS_TEST_UPLOAD_FILE_NAME`: The test file to be uploaded.
- `$AWS_TEST_UPLOAD_TYPE`: The upload type of the test.
- `$AWS_TEST_UPLOAD_FILE_PATH`: The file path for the test upload.
