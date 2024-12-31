#!/bin/bash
#the two lines below are new for Amazon Linux2
sudo yum -y remove python37
sudo amazon-linux-extras install -y python3.8
sudo update-alternatives --set python /usr/bin/python3.8
sudo ln -sf /usr/bin/python3.8 /usr/bin/python3
sudo ln -sf /usr/bin/python3.8 /usr/bin/python
sudo ln -sf /usr/bin/pip3.8 /usr/bin/pip
sudo ln -sf /usr/bin/pip3.8 /usr/bin/pip3
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm awscliv2.zip
pip install boto3

echo Please enter a valid IP address:
read ip_address
echo IP address:$ip_address
echo Please wait...
#sudo pip install --upgrade awscli
bucket="cloud-computing-gym-project-bucket-webpage"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

FILE_PATH="/home/ec2-user/environment/gym-webpage/resources/public_policy.json"
FILE_PATH_2="/home/ec2-user/environment/gym-webpage/resources/permissions.py"
FILE_PATH_3="/home/ec2-user/environment/gym-webpage/resources/website/config.js"
FILE_PATH_4="/home/ec2-user/environment/gym-webpage/python_3/update_config.py"

sed -i "s/<FMI_1>/$bucket/g" $FILE_PATH
sed -i "s/<FMI_1>/$bucket/g" $FILE_PATH_4
sed -i "s/<FMI_2>/$ip_address/g" $FILE_PATH
sed -i "s/<FMI>/$bucket/g" $FILE_PATH_2

#DISABLE PAGER
aws configure set cli_pager ""

#Create bucket s3 for webpage
aws s3 mb s3://$bucket
#Create apigateway
python ~/environment/gym-webpage/python_3/create_products_api.py
python ~/environment/gym-webpage/python_3/create_popular_api.py
python ~/environment/gym-webpage/python_3/create_user_get_api.py

apigateway=`aws apigateway get-rest-apis | grep id | cut -f2- -d: | tr -d ',' | xargs`
aws apigateway create-deployment \
    --rest-api-id $apigateway \
    --stage-name prod
invoke_url="https://$apigateway.execute-api.us-east-1.amazonaws.com/prod"

sed -i "s@<FMI_1>@$invoke_url@g" $FILE_PATH_3
python ~/environment/gym-webpage/python_3/update_config.py
#Create dynamoDB
python ~/environment/gym-webpage/python_3/create_table.py
python ~/environment/gym-webpage/python_3/add_gsi.py
cd ~/environment/gym-webpage/python_3
zip get_all_products_code.zip get_all_products_code.py
zip get_all_users_code.zip get_all_users_code.py

aws s3 cp ~/environment/gym-webpage/resources/website s3://$bucket/ --recursive --cache-control "max-age=0"
aws s3 cp ~/environment/gym-webpage/python_3/get_all_products_code.zip  s3://$bucket
aws s3 cp ~/environment/gym-webpage/python_3/get_all_users_code.zip  s3://$bucket

python ~/environment/gym-webpage/resources/permissions.py
python ~/environment/gym-webpage/resources/seed.py

ROLE_ARN=$(aws iam get-role --role-name LambdaAccessToDynamoDB --query 'Role.Arn' --output text)

FILE_PATH_5="/home/ec2-user/environment/gym-webpage/python_3/get_all_products_wrapper.py"
FILE_PATH_6="/home/ec2-user/environment/gym-webpage/python_3/get_all_users_wrapper.py"

sed -i "s@<FMI_ROLE>@$ROLE_ARN@g" $FILE_PATH_5
sed -i "s@<FMI_ROLE>@$ROLE_ARN@g" $FILE_PATH_6
sed -i "s@<FMI_BUCKET>@$bucket@g" $FILE_PATH_5
sed -i "s@<FMI_BUCKET>@$bucket@g" $FILE_PATH_6

python ~/environment/gym-webpage/python_3/get_all_products_wrapper.py
python ~/environment/gym-webpage/python_3/get_all_users_wrapper.py

MEMBERSHIPS_RESOURCE_ID=$(aws apigateway get-resources --rest-api-id $apigateway --query "items[?path=='/memberships'].id" --output text)
POPULAR_RESOURCE_ID=$(aws apigateway get-resources --rest-api-id $apigateway --query "items[?path=='/memberships/popular'].id" --output text)
USERS_RESOURCE_ID=$(aws apigateway get-resources --rest-api-id $apigateway --query "items[?path=='/users'].id" --output text)
LAMBDA_ARN=$(aws lambda get-function --function-name get_all_products --query 'Configuration.FunctionArn' --output text)
LAMBDA_USERS_ARN=$(aws lambda get-function --function-name get_user --query 'Configuration.FunctionArn' --output text)

aws lambda add-permission \
    --region us-east-1 \
    --function-name get_all_products \
    --principal apigateway.amazonaws.com \
    --statement-id apigateway-get-memberships \
    --action "lambda:InvokeFunction" \
    --source-arn arn:aws:execute-api:us-east-1:$AWS_ACCOUNT_ID:$apigateway/*/GET/memberships

aws lambda add-permission \
    --region us-east-1 \
    --function-name get_all_products \
    --principal apigateway.amazonaws.com \
    --statement-id apigateway-get-popular \
    --action "lambda:InvokeFunction" \
    --source-arn arn:aws:execute-api:us-east-1:$AWS_ACCOUNT_ID:$apigateway/*/GET/memberships/popular

aws lambda add-permission \
    --region us-east-1 \
    --function-name get_user \
    --principal apigateway.amazonaws.com \
    --statement-id apigateway-get-user \
    --action "lambda:InvokeFunction" \
    --source-arn arn:aws:execute-api:us-east-1:$AWS_ACCOUNT_ID:$apigateway/*/GET/users

aws apigateway put-integration \
        --region us-east-1 \
        --rest-api-id $apigateway \
        --resource-id $MEMBERSHIPS_RESOURCE_ID \
        --http-method GET \
        --type AWS \
        --integration-http-method POST \
        --uri arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/$LAMBDA_ARN/invocations \
        --passthrough-behavior WHEN_NO_TEMPLATES \
        --timeout-in-millis 29000


aws apigateway put-integration-response \
        --region us-east-1 \
        --rest-api-id $apigateway \
        --resource-id $MEMBERSHIPS_RESOURCE_ID \
        --http-method GET \
        --status-code 200 \
        --selection-pattern "" --response-templates '{"application/json": ""}'


aws apigateway put-integration \
        --region us-east-1 \
        --rest-api-id $apigateway \
        --resource-id $POPULAR_RESOURCE_ID \
        --http-method GET \
        --type AWS \
        --integration-http-method POST \
        --uri arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/$LAMBDA_ARN/invocations \
        --passthrough-behavior WHEN_NO_TEMPLATES \
        --timeout-in-millis 29000 

aws apigateway put-integration-response \
        --region us-east-1 \
        --rest-api-id $apigateway \
        --resource-id $POPULAR_RESOURCE_ID \
        --http-method GET \
        --status-code 200 \
        --selection-pattern "" \
        --response-templates '{"application/json": "{\"membership_item_arr\": [#foreach($item in $input.path(\"$.membership_item_arr\")) #if($item.tag_str_arr.contains(\"popular\")){\"price_in_cents_int\": $item.price_in_cents_int,\"special_int\": $item.special_int,\"tag_str_arr\": $item.tag_str_arr,\"description_str\": \"$item.description_str\",\"membership_name_str\": \"$item.membership_name_str\",\"membership_id_str\": \"$item.membership_id_str\"} #if($foreach.hasNext),#end #end #end {}]}"}' 

aws apigateway put-integration \
        --region us-east-1 \
        --rest-api-id $apigateway \
        --resource-id $USERS_RESOURCE_ID \
        --http-method GET \
        --type AWS \
        --integration-http-method POST \
        --uri arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/$LAMBDA_USERS_ARN/invocations \
        --passthrough-behavior WHEN_NO_TEMPLATES \
        --timeout-in-millis 29000 \
        --request-templates '{"application/json": "{\"username\": \"$input.params(\"username\")\", \"password\": \"$input.params(\"password\")\"}"}'

aws apigateway put-integration-response \
        --region us-east-1 \
        --rest-api-id $apigateway \
        --resource-id $USERS_RESOURCE_ID \
        --http-method GET \
        --status-code 200 \
        --selection-pattern "" --response-templates '{"application/json": ""}'

aws apigateway create-deployment \
    --rest-api-id $apigateway \
    --stage-name prod