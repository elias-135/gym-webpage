import boto3

def create_table():

    DDB = boto3.resource('dynamodb', region_name='us-east-1')

    params = {
        'TableName': 'memberships_db',
        'KeySchema': [
            {'AttributeName': 'membership_name', 'KeyType': 'HASH'}
        ],
        'AttributeDefinitions': [
            {'AttributeName': 'membership_name', 'AttributeType': 'S'}
        ],
        'ProvisionedThroughput': {
            'ReadCapacityUnits': 1,
            'WriteCapacityUnits': 1
        }
    }
    table = DDB.create_table(**params)
    table.wait_until_exists()
    print ("Done table memberships")

    params = {
    'TableName': 'users',
    'KeySchema': [
        {'AttributeName': 'user_name', 'KeyType': 'HASH'}  # Define HASH key
    ],
    'AttributeDefinitions': [
        {'AttributeName': 'user_name', 'AttributeType': 'S'}  # Match HASH key type
    ],
    'ProvisionedThroughput': {
        'ReadCapacityUnits': 1,
        'WriteCapacityUnits': 1
    }

    }
    table = DDB.create_table(**params)

    table.wait_until_exists()
    
    print ("Done table users")

    

if __name__ == '__main__':
    create_table()