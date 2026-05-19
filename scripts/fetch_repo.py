import requests

# GitHub API endpoint
url = "https://api.github.com/repos/EU-ECDC/Respiratory_viruses_weekly_data/contents/data/"

response = requests.get(url)

# Kontrollime, kas päring õnnestus
if response.status_code == 200:
    data = response.json()

    print("Repo sisu:")
    for item in data:
        print(f"{item['type']:4} | {item['name']}")
else:
    print("Viga:", response.status_code)
    print(response.text)


# Vaata snapshots kausta
url2 = "https://api.github.com/repos/EU-ECDC/Respiratory_viruses_weekly_data/contents/data/snapshots/"
response2 = requests.get(url2)
data2 = response2.json()

print("\nSnapshots sisu:")
for item in data2:
    print(f"{item['type']:4} | {item['name']}")