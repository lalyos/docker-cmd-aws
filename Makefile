IMAGE=lalyos/cmd-aws

build:
	docker build . -t $(IMAGE)

push: build
	docker push $(IMAGE)

run: build
	docker run --rm -it \
	  -e AWS_ROLE_ARN=$$AWS_ROLE_ARN \
	  -e AWS_ACCESS_KEY_ID=$$AWS_ACCESS_KEY_ID \
	  -e AWS_SECRET_ACCESS_KEY=$$AWS_SECRET_ACCESS_KEY \
	  $(IMAGE)
