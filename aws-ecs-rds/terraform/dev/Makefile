
init:
	tflint --init
	terraform init

fmt:
	terraform fmt -recursive -diff ../

validate: fmt
	terraform validate
	tflint -f compact

plan: validate
	terraform plan
