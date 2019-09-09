modules = $(shell find . -type f -name "*.tf" -exec dirname {} \;|sort -u)
google_region = $(shell grep -r region tests/tests.tfvars | awk '{print $$3}')
google_project = $(shell grep -r project tests/tests.tfvars | awk '{print $$3}')
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

nat_compare: init
	gcloud container clusters get-credentials primary-cluster-regional-nat --region $(google_region) --project $(google_project)
	actual_pod_ip=$(shell kubectl run -it --generator=run-pod/v1 curl --image appropriate/curl -- curl ifconfig.co 2>/dev/null)
	cloud_nat_ip=$(shell gcloud compute addresses describe default-primary-cluster-regional-nat-nat-external-address --region $(google_region) --project $(google_project) |grep 'address:'| awk '{print $2}')
	test  "$(actual_pod_ip)" == "$(cloud_nat_ip)"

destroy: init
	terraform plan --destroy -var-file=$(test_dir)/tests.tfvars -out=.plan $(test_dir)
	terraform apply ".plan"