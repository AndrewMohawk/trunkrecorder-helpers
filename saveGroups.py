import requests
import csv
import sys
import json


email = "email"
password = "password"
shortname = "shortname"

if len(sys.argv) != 2:
    print("python3 saveGroups.py <openmhzuploadedfile>")
    sys.exit(0)

if email == "email" or password == "password" or shortname == "shortname":
    print("Please modify the email, password and shortname before running this script.")
    sys.exit(1)

headers = {"content-type": "application/json"}
loginURL = "https://account.openmhz.com/login"


data = {"email": email, "password": password}
r = requests.post(loginURL, headers=headers, data=json.dumps(data))
response = r.json()
if response["success"] == True:
    cookies = {"sessionId": r.headers["set-cookie"][10:]}
    groups = {}
    with open(sys.argv[1]) as csvfile:
        readCSV = csv.reader(csvfile, delimiter=",")
        for row in readCSV:
            dec = row[0]
            group_name = row[5]
            if group_name in groups:
                groups[group_name].append(dec)
            else:
                groups[group_name] = [dec]

    print(
        "Adding the following groups to the system with shortname {}:".format(shortname)
    )

    url = "https://admin.openmhz.com/groups/{}".format(shortname)
    # url = "http://localhost:9123"
    for groupName, groupKeys in groups.items():
        headers = {"content-type": "application/json"}

        requestData = {
            "shortname": shortname,
            "groupName": groupName,
            "talkgroups": json.dumps(groupKeys),
        }

        r_group = requests.post(
            url, headers=headers, data=json.dumps(requestData), cookies=cookies
        )
        response_group = r_group.json()
        if response_group["success"] == True:
            print("Uploaded group: '{}' successfully".format(groupName))
        else:
            print(
                "ERROR! Could not upload group: {}, reponse: {}".format(
                    groupName, response_group
                )
            )

else:
    print("Invalid username or password, response: \n{}".format(r.json()))

