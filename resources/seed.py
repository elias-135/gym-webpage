import boto3, json


def batch_put(membership_list):
    DDB = boto3.resource('dynamodb', region_name='us-east-1')
    table = DDB.Table('memberships_db')
    with table.batch_writer() as batch:
        for membership in membership_list:
            membership_name = membership['membership_name_str']
            membership_id = membership['membership_id_str']
            price_in_cents = membership['price_in_cents_int']
            description = membership['description_str']
            tags = membership['tag_str_arr']
            formatted_data  = {
                'membership_name': membership_name,
                'membership_id': membership_id,
                'price_in_cents': price_in_cents,
                'description': description,
                'tags': tags
            }
            if 'special_int' in membership:
                formatted_data['special'] = membership['special_int']
                print("Adding special food item:", membership_name, price_in_cents)
            else:
                print("Adding food item:", membership_name, price_in_cents)
                pass
            batch.put_item(Item=formatted_data)

def users_put(user_list):
    DDB = boto3.resource('dynamodb', region_name='us-east-1')
    table = DDB.Table('users')
    with table.batch_writer() as batch:
        for user in user_list:
            user_name = user['user_name_str']
            password = user['password']
            membership_id_arr = user['membership_id_arr']
            membership_name_arr = user['membership_name_arr']
            
            
            formatted_data = {
                'user_name': user_name,
                'password': password,
                'membership_ids': membership_id_arr,
                'membership_names': membership_name_arr
            }
            
            # Print user info for logging
            print("Adding user:", user_name)
            
            # Add the user data to DynamoDB
            batch.put_item(Item=formatted_data)


if __name__ == '__main__':
    with open("/home/ec2-user/environment/gym-webpage/resources/website/all_memberships.json") as json_file:
        membership_list = json.load(json_file)["membership_item_arr"]
    batch_put(membership_list)

    with open("/home/ec2-user/environment/gym-webpage/resources/website/all_users.json") as json_file:
        user_list = json.load(json_file)["user_item_arr"]
    users_put(user_list)

