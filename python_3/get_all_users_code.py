import boto3, json
from boto3.dynamodb.conditions import Key
from boto3.dynamodb.conditions import Key, Attr, Not

TABLE_NAME_STR = 'users'
DDB = boto3.resource('dynamodb', region_name='us-east-1')
    
def lambda_handler(event, other):
    DDB = boto3.resource('dynamodb', region_name='us-east-1')
    TABLE = DDB.Table(TABLE_NAME_STR)
     
    username = event.get('username', None)
    password = event.get('password', None)
    if not username:
        return {
            "statusCode": 400,
            "body": "Username is required"
        }
    response = TABLE.scan(
        FilterExpression=boto3.dynamodb.conditions.Attr('user_name').eq(username)
    )

    data = response['Items']

    if (data[0]['user_name'] == username and data[0]['password'][0] == password):
        for item in data:
            item['user_name_str'] = item.pop('user_name')
            item['membership_id_arr'] = item.pop('membership_ids')
            item['membership_name_arr'] = item.pop('membership_names')
            item.pop('password')
        return_me={"user_item_arr": data}
        return return_me