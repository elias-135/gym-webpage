import boto3, json

client = boto3.client('apigateway', region_name='us-east-1')

api_id = client.get_rest_apis()['items'][0]['id']

resources = client.get_resources(restApiId=api_id)
root_id = [resource for resource in resources["items"] if resource["path"] == "/"][0]["id"]




report_resource = client.create_resource(
    restApiId=api_id,
    parentId=root_id,
    pathPart='users'
)
report_resource_id = report_resource["id"]



report_method = client.put_method(
    restApiId=api_id,
    resourceId=report_resource_id,
    httpMethod='POST',
    authorizationType='NONE'
)

report_response = client.put_method_response(
    restApiId=api_id,
    resourceId=report_resource_id,
    httpMethod='POST',
    statusCode='200',
    responseParameters={
        'method.response.header.Access-Control-Allow-Headers': False,
        'method.response.header.Access-Control-Allow-Origin': False,
        'method.response.header.Access-Control-Allow-Methods': False
    },
    responseModels={
        'application/json': 'Empty'
    }
)

report_integration = client.put_integration(
    restApiId=api_id,
    resourceId=report_resource_id,
    httpMethod='POST',
    type='MOCK',
    requestTemplates={
        'application/json': '{"statusCode": 200}'
    }
)


report_integration_response = client.put_integration_response(
    restApiId=api_id,
    resourceId=report_resource_id,
    httpMethod='POST',
    statusCode='200',
    responseParameters={
        'method.response.header.Access-Control-Allow-Headers': '\'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token\'',
        'method.response.header.Access-Control-Allow-Methods': '\'POST\'',
        'method.response.header.Access-Control-Allow-Origin': '\'*\''
    },
    responseTemplates={
        "application/json": json.dumps({
            "user_item_arr": [
                {
                    "user_name_str": "Elian Garcia",
                    "membership_id_arr": ["m003", "m005"],
                    "membership_name_arr": ["gold", "vip"]
                }
            ]
        })
    }
)


print ("DONE")
"""
Copyright @2021 [Amazon Web Services] [AWS]
    
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
"""
