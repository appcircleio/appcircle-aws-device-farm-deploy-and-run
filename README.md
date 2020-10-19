# AWS Device Farm Deploy and Run

Deploy a file to AWS Device Farm and run tests.

Releated Documentation
- https://docs.aws.amazon.com/cli/latest/reference/devicefarm/create-upload.html
- https://docs.aws.amazon.com/cli/latest/reference/devicefarm/schedule-run.html

Required Input Variables
- `$AWS_ACCESS_KEY_ID`: Amazon S3 access key id
- `$AWS_SECRET_ACCESS_KEY`: AAmazon S3 secret access key (Visit [AWS access keys documentation](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys) for details)
- `$AWS_PROJECT_ARN`: The ARN of the project for deploy and run
- `$AWS_DEVICE_POOL_ARN`: The ARN of the device pool for the run
- `$AWS_SCHEDULE_RUN_NAME`: The name for the run to be scheduled
- `$AWS_SCHEDULE_TEST_TYPE`: The test's type
- `$AWS_UPLOAD_TIMEOUT`: Upload timeout. (second)
- `$AWS_TEST_TIMEOUT`: Test timeout. (second)
- `$AWS_APP_ARN`: The ARN of an application package to run tests against, created with CreateUpload. If you don't have this parameter, AWS App Upload File Name, AWS App Upload Type, AWS App Upload File Path parameters required.
- `$AWS_APP_UPLOAD_FILE_NAME`: The upload's file name. The name should not contain any forward slashes (/ ). If you are uploading an iOS app, the file name must end with the .ipa extension. If you are uploading an Android app, the file name must end with the .apk extension.
- `$AWS_APP_UPLOAD_TYPE`: The upload's upload type.
- `$AWS_APP_UPLOAD_FILE_PATH`: The upload's file path.
- `$AWS_TEST_ARN`: The ARN of the uploaded test to be run. If you don't have this parameter, AWS Test Upload File Name, AWS Test Upload Type, AWS App Upload File Path parameters required.
- `$AWS_TEST_UPLOAD_FILE_NAME`: The file name must end with the .zip file extension.
- `$AWS_TEST_UPLOAD_FILE_NAME`: The upload's upload type.
- `$AWS_TEST_UPLOAD_FILE_PATH`: The upload's file path.

Optional Input Variables
- `$AWS_TEST_UPLOAD_TYPE`: Amazon S3 bucket region. Defaults to `us-west-2`
