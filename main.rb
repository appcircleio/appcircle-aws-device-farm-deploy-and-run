require 'open3'
require 'os'
require 'json'
require 'timeout'

def get_env_variable(key)
	return (ENV[key] == nil || ENV[key] == "") ? nil : ENV[key]
end

ac_aws_access_key_id = get_env_variable("AWS_ACCESS_KEY_ID") || abort('Missing aws access key id.')
ac_aws_secret_access_key = get_env_variable("AWS_SECRET_ACCESS_KEY") || abort('Missing aws secret key.')
ac_aws_default_region = get_env_variable("AWS_DEFAULT_REGION") || ENV["AWS_DEFAULT_REGION"] = "us-west-2"
ac_aws_project_arn = get_env_variable("AWS_PROJECT_ARN") || abort('Missing aws project arn.')
ac_aws_device_pool_arn = get_env_variable("AWS_DEVICE_POOL_ARN") || abort('Missing aws device pool arn.')
ac_build_number = get_env_variable("AC_BUILD_NUMBER") 

#https://docs.aws.amazon.com/cli/latest/reference/devicefarm/schedule-run.html
ac_aws_schedule_run_name_prefix = get_env_variable("AWS_SCHEDULE_RUN_NAME_PREFIX") || abort('Missing aws schedule run name prefix.')
ac_aws_schedule_test_type = get_env_variable("AWS_SCHEDULE_TEST_TYPE") || abort('Missing aws schedule test type.')

ac_aws_upload_timeout = get_env_variable("AWS_UPLOAD_TIMEOUT").to_i || abort('Missing aws upload timeout.')
ac_aws_test_timeout = get_env_variable("AWS_TEST_TIMEOUT").to_i || abort('Missing aws test timeout.')

#https://docs.aws.amazon.com/cli/latest/reference/devicefarm/create-upload.html
ac_aws_app_arn = get_env_variable("AWS_APP_ARN")
unless ac_aws_app_arn
	ac_aws_app_upload_file_name = get_env_variable("AWS_APP_UPLOAD_FILE_NAME") || abort('Missing aws app upload file name.')
	ac_aws_app_upload_type = get_env_variable("AWS_APP_UPLOAD_TYPE") || abort('Missing aws app upload type.')
	ac_aws_app_upload_file_path = get_env_variable("AWS_APP_UPLOAD_FILE_PATH") || abort('Missing aws app upload file path.')
end

#https://docs.aws.amazon.com/cli/latest/reference/devicefarm/create-upload.html
ac_aws_test_arn = get_env_variable("AWS_TEST_ARN")
unless ac_aws_test_arn
	ac_aws_test_upload_file_name = get_env_variable("AWS_TEST_UPLOAD_FILE_NAME") || abort('Missing aws test upload file name.')
	ac_aws_test_upload_type = get_env_variable("AWS_TEST_UPLOAD_TYPE") || abort('Missing aws test upload type.')
	ac_aws_test_upload_file_path = get_env_variable("AWS_TEST_UPLOAD_FILE_PATH") || abort('Missing aws test upload file path.')
end

#https://docs.aws.amazon.com/cli/latest/reference/devicefarm/create-upload.html
ac_aws_test_spec_arn = get_env_variable("AWS_TEST_SPEC_ARN")
unless ac_aws_test_arn
	ac_aws_test_spec_upload_file_name = get_env_variable("AWS_TEST_SPEC_UPLOAD_FILE_NAME")
	ac_aws_test_spec_upload_type = get_env_variable("AWS_TEST_SPEC_UPLOAD_TYPE")
	ac_aws_test_spec_upload_file_path = get_env_variable("AWS_TEST_SPEC_UPLOAD_FILE_PATH")
end

AWS_DOWNLOAD_URL_FOR_LINUX = "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
AWS_DOWNLOAD_URL_FOR_MACOS = "https://awscli.amazonaws.com/AWSCLIV2.pkg"

def run_command(command)
    puts "@@[command] #{command}"
    output = `#{command}`
    puts "#{output}"
    
    if $?.exitstatus != 0
    	exit $?.exitstatus
    end
    return output
end

def install_aws_cli
	system("aws --version")
	if $?.success?
		return
	end

	if OS.mac?
		run_command("curl #{AWS_DOWNLOAD_URL_FOR_MACOS} -o \"AWSCLIV2.pkg\"")
		run_command("sudo installer -pkg AWSCLIV2.pkg -target /")
	else
		run_command("curl #{AWS_DOWNLOAD_URL_FOR_LINUX} -o \"awscliv2.zip\"")
		run_command("unzip awscliv2.zip && ./aws/install")
	end
end

def create_upload(project_arn,upload_file_name,upload_type,file_path)
	output_create_upload = run_command("aws devicefarm create-upload --project-arn \"#{project_arn}\" --name \"#{upload_file_name}\" --type #{upload_type}")
	output_create_upload = JSON.parse(output_create_upload)
	upload_url = output_create_upload["upload"]["url"]
	upload_arn = output_create_upload["upload"]["arn"]
	run_command("curl -T \"#{file_path}\" \"#{upload_url}\"")
	return upload_arn
end

def check_upload(arn,check_count)
	if check_count <= 0 
		puts "Error: App upload timed out."
		exit 1
	end
	output_get_upload = run_command("aws devicefarm get-upload --arn \"#{arn}\"")
	output_get_upload = JSON.parse(output_get_upload)
	status = output_get_upload["upload"]["status"]
	if status == "FAILED"
		puts "Error: App upload failed."
		exit 1
	elsif status == "SUCCEEDED"
		return true
	end 

	sleep(1)
	return check_upload(arn,check_count - 1)
end

def check_test(arn,check_count)
	if check_count <= 0 
		puts "Warning: Maximum waiting time for test results exceeded."
		exit 0
	end
	output_get_run= run_command("aws devicefarm get-run --arn \"#{arn}\"")
	output_get_run = JSON.parse(output_get_run)
	status = output_get_run["run"]["status"]
	if status == "COMPLETED"
		return true
	end 

	sleep(10)
	return check_test(arn,check_count - 10)
end

install_aws_cli()

#Application File
unless ac_aws_app_arn
	#Upload Application File
	upload_app_arn = create_upload(ac_aws_project_arn,ac_aws_app_upload_file_name,ac_aws_app_upload_type,ac_aws_app_upload_file_path)
else
	upload_app_arn = ac_aws_app_arn
end

check_upload(upload_app_arn,ac_aws_upload_timeout)

#Test File
unless ac_aws_test_arn
	#Upload Test File
	upload_test_arn = create_upload(ac_aws_project_arn,ac_aws_test_upload_file_name,ac_aws_test_upload_type,ac_aws_test_upload_file_path)
else
	upload_test_arn = ac_aws_test_arn
end

check_upload(upload_test_arn,ac_aws_upload_timeout)

#Test Spec File
unless ac_aws_test_spec_arn
	#Upload Test Spec File
	if ac_aws_test_spec_upload_file_name && ac_aws_test_spec_upload_type && ac_aws_test_spec_upload_file_path
		upload_test_spec_arn = create_upload(ac_aws_project_arn,ac_aws_test_spec_upload_file_name,ac_aws_test_spec_upload_type,ac_aws_test_spec_upload_file_path)
	end
else
	upload_test_spec_arn = ac_aws_test_spec_arn
end

if upload_test_spec_arn
	check_upload(upload_test_spec_arn,ac_aws_upload_timeout)
end

ac_aws_schedule_run_name="#{ac_aws_schedule_run_name_prefix}_#{ac_build_number}"
#Schedule Test
schedule_run_command = "aws devicefarm schedule-run"
schedule_run_command.concat(" ")
schedule_run_command.concat("--project-arn \"#{ac_aws_project_arn}\"")
schedule_run_command.concat(" ")
schedule_run_command.concat("--app-arn \"#{upload_app_arn}\"")
schedule_run_command.concat(" ")
schedule_run_command.concat("--device-pool-arn \"#{ac_aws_device_pool_arn}\"")
schedule_run_command.concat(" ")
schedule_run_command.concat("--name \"#{ac_aws_schedule_run_name}\"")
schedule_run_command.concat(" ")
if upload_test_spec_arn
	schedule_run_command.concat("--test type=#{ac_aws_schedule_test_type},testPackageArn=#{upload_test_arn},testSpecArn=#{upload_test_spec_arn}")
else
	schedule_run_command.concat("--test type=#{ac_aws_schedule_test_type},testPackageArn=#{upload_test_arn}")
end


output_schedule_run = run_command(schedule_run_command)
output_schedule_run = JSON.parse(output_schedule_run)
schedule_run_arn = output_schedule_run["run"]["arn"]

check_test(schedule_run_arn,ac_aws_test_timeout)


exit 0
