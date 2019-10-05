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

nat_verify: 
	gcloud components install kubectl -q
	gcloud container clusters get-credentials primary-cluster-regional-nat --region $(google_region) --project $(google_project)
	### Waiting for dns in the cluster to be ready
	until [ `kubectl run curl --rm --restart=Never -it --image=appropriate/curl --generator=run-pod/v1 --wait  -- -fsSL http://ifconfig.co |grep -oE '([0-9]{1,3}[\.]){3}[0-9]{1,3}'` ]; do echo "Waiting for dns in the cluster to be ready" ; sleep 60; done
	### compare actual external IP with google NAT IP
	ACTUAL_IP=`kubectl run curl --rm --restart=Never -it --image=appropriate/curl --generator=run-pod/v1 --wait  -- -fsSL http://ifconfig.co | grep -oE '([0-9]{1,3}[\.]){3}[0-9]{1,3}'` ;\
	NAT_IP=`gcloud compute addresses describe default-primary-cluster-regional-nat-nat-external-address --region $(google_region) --project $(google_project) |grep 'address:'| awk '{print $$2}'` ;\
	echo "Discovered IP is: $$ACTUAL_IP" ;\
	echo "Google Nat IP is: $$NAT_IP" ;\
	if [ "$$ACTUAL_IP" != "$$NAT_IP" ];then exit 1; fi


destroy: init
	terraform plan --destroy -var-file=$(test_dir)/tests.tfvars -out=.plan $(test_dir)
	terraform apply ".plan"