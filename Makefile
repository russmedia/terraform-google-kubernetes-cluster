modules = $(shell find . -type f -name "*.tf" -exec dirname {} \;|sort -u)
test_dir=tests

.PHONY: test

default: validate

init:
	rm -rf .terraform
	@for m in $(modules); do (terraform init $$m); done

validate: init
	@for m in $(modules); do (terraform validate -var-file=tests/tests.tfvars "$$m" && echo "√ $$m") || exit 1 ; done

fmt: init
	@if [ `terraform fmt | wc -c` -ne 0 ]; then echo "terraform files need be formatted"; exit 1; fi

test: init
	terraform plan -var-file=$(test_dir)/tests.tfvars -out=.plan $(test_dir)
	terraform apply ".plan"

destroy: init
	terraform plan --destroy -var-file=$(test_dir)/tests.tfvars -out=.plan $(test_dir)
	terraform apply ".plan"