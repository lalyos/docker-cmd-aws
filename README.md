
aws cli doesn't provide cross region list functionality. Lets fix it!

## Listing

```
export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

docker run -it \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  lalyos/cmd-aws
```


## Using an IAM Role

best pratice, least privileged, use roles ...

aws cli doesnt provide an env variable for role base auth. Lets introduce `$AWS_ROLE_ARN`

```
docker run -it \
  -e AWS_ROLE_ARN=$AWS_ROLE_ARN \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  lalyos/cmd-aws
```

## Restricting regions
...

## Changing the fields

```
QUERY='id: InstanceId, region: Placement.AvailabilityZone, started: LaunchTime, pubIp: PublicIpAddress'
docker run -it \
  -e AWS_ROLE_ARN=$AWS_ROLE_ARN \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  -e "QUERY=$QUERY" \
  lalyos/cmd-aws

```

## Complex fields

awscli uses [JMesPath](http://jmespath.org) for restricting fields, filtering/sorting arrays. But it uses all quotation marks: single, double even backtick.
So if you want to pass a complicated awscli query parameter for example which includes space and backtick, you are entering the quotation hell.
Or use `QUERY_BASE64` which will be bas64 decoded in the containers entrypoint script.

```
QUERY='id: InstanceId, region: Placement.AvailabilityZone, started: LaunchTime, pubIp: PublicIpAddress, stack: join(``, Tags[?Key==`aws:cloudformation:stack-name`].Value || `[]`), name: join(``, Tags[?Key==`Name`].Value || `[]`), owner: join(``, Tags[?(Key==`owner` || Key==`Owner`)].Value || `[]`) '
QUERY='id: InstanceId, region: Placement.AvailabilityZone, started: LaunchTime, pubIp: PublicIpAddress,  name: join(``, Tags[?Key==`Name`].Value || `[]`)'
QUERY_BASE64=$(base64 <<< $QUERY)

docker run -it \
  -e AWS_ROLE_ARN=$AWS_ROLE_ARN \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  -e QUERY_BASE64=$(base64 <<< $QUERY) \
  lalyos/cmd-aws
```

## cmd.io

Create ssh config for cmd.io which reuses a "background" ssh connection
```
cat >> ~/.ssh/config <<EOF
Host cmd
    Hostname alpha.cmd.io
    User yourgithubname
    ControlMaster auto
    ControlPath /tmp/%r@%h:%p
    ControlPersist yes
EOF
```
install and configure the command
```
ssh cmd :add ec2-list lalyos/cmd-aws
ssh cmd ec2-list:config set \
  AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  AWS_ROLE_ARN=$AWS_ROLE_ARN
```

change 
```
QUERY='id: InstanceId, region: Placement.AvailabilityZone, started: LaunchTime, pubIp: PublicIpAddress,  name: join(``, Tags[?Key==`Name`].Value || `[]`)'
QUERY_BASE64=$(base64 <<< $QUERY)

ssh cmd ec2-list:config set QUERY_BASE64=$QUERY_BASE64
```

now you can run it as:
```
ssh cmd ec2-list
```


## cmd.io notes

optional "docker pull"
