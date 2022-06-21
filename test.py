cube = 'wowgybwyogygybyoggrowbrgywrborwggybrbwororbwborgowryby'

import requests

payload = {
	"cube": cube
}

r = requests.post("http://localhost:5000/solve", json=payload)
print(r.text)
