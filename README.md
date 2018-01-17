# WildRydes Terraform/Serverless Framework

This project uses terraform and serverless to create AWSLabs' WildRydes tutorial project: https://github.com/awslabs/aws-serverless-workshops/tree/master/WebApplication

To follow along you will need AWS CLI, Terraform and Serverless Framework installed and configured.
```sh
npm install -g serverless
brew update && brew install awscli terraform
```

## Deploying

### Terraform

from the `terraform` directory:

```sh
terraform init
terraform plan
# confirm all is well, correct aws account etc.
terraform apply
```

AWS Cognito manages our user membership, and an S3 bucket for static site hosting will have been created as well as populated with files for the project application.

The output from a successful `apply` will include some important identifiers for the resources created and the URL to visit our new web application.

### Serverless Framework

Copy the `cognito_user_pool_arn` from the output and pass the value in as an option to `sls deploy`

```sh
cd ../serverless/
sls deploy --POOL_ARN ARN_YOU_COPIED
```

Serverless Framework will have now deployed our DynamoDB table, API, and Lambda function.

## Updating Application config.js

Create a new file anywhere (locally) called `config.js` and paste this js snippet in. Fill in the values from output seen post-deploy. `invokeUrl` will come from `sls deploy` output as the **base url** for the "requestUnicorn" endpoint.

example:
endpoints:
`POST - https://9ndfz9bgce.execute-api.us-east-1.amazonaws.com/dev/ride` would make my invokeUrl `https://9ndfz9bgce.execute-api.us-east-1.amazonaws.com/dev`

```js
window._config = {
  cognito: {
    userPoolId: '', // e.g. us-east-2_uXboG5pAb
    userPoolClientId: '', // e.g. 25ddkmj4v6hfsfvruhpfi7n4hv
    region: '' // e.g. us-east-2
  },
  api: {
    invokeUrl: '' // e.g. https://rc7nyt4tql.execute-api.us-west-2.amazonaws.com/prod',
  }
};
```

## Upload config to S3

The bucket's name will have been in the terraform output

```sh
aws s3 cp config.js s3://BUCKET_NAME/js/config.js
```

## Teardown

```sh
# within serverless/ dir
sls remove

# within terraform/ dir
terraform destroy
```
