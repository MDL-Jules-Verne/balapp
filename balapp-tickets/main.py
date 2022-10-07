import csv

import qrcode
from qrcode.image.styledpil import StyledPilImage
import qrcode.image.svg
import random
import string
import time
from PIL import Image, ImageDraw, ImageFont

chars = "RTPQSDFGHJKLWXCVB3456789"
openSans = ImageFont.truetype('openSans.ttf', 34)
openSansMini = ImageFont.truetype('openSans.ttf', 24)
colors = ["green", "red", "blue", "yellow"]
colorsFrench = ["vert", "rouge", "bleu", "jaune"]
idLength = 4


def get_random_string(size):
    return ''.join(random.choice(chars) for _ in range(size))


usedIds = []
fullDb = []
colorNb = 0
roomNb = 1
execStart = time.time()
for i in range(1, 501):
    ticketData = {}
    qr = qrcode.QRCode(
        version=1,
        border=1,
        box_size=8,
        error_correction=qrcode.constants.ERROR_CORRECT_H,
    )
    hasGeneratedId = False
    data = get_random_string(idLength)
    while data in usedIds:
        data = get_random_string(idLength)
    ticketData["id"] = data
    qr.add_data(data)
    usedIds.append(data)

    img = qr.make_image(image_factory=StyledPilImage, embeded_image_path="logo.jpg")
    img.save(f"generated_qrs/output{i}.png")
    qr_image = Image.open(f"generated_qrs/output{i}.png", )
    ticket = Image.new(mode="RGBA", size=(1000, 250), color=colors[colorNb])
    ticketData["couleur"] = colorsFrench[colorNb]

    ticket.paste(qr_image, (1000 - 210, 15))
    I1 = ImageDraw.Draw(ticket)
    I1.text((150, 100), "Bal d'hiver Lycée Jules Verne 2022", fill=(0, 0, 0), font=openSans)

    I1.text((1000 - 170, 197), data, fill=(0, 0, 0), font=openSans)
    I1.text((40, 200), f"Vestiaire: {roomNb}", fill=(0, 0, 0), font=openSansMini)
    ticketData["salle"] = roomNb

    # ticket.show()
    ticket.save(f"generated_qrs/output{i}.png")
    fullDb.append(ticketData)
    colorNb += 1
    if colorNb >= len(colors):
        colorNb = 0
        roomNb += 1
        if roomNb >= 5:
            roomNb = 1
    if i % 300 == 0:
        print(i)

print(time.time() - execStart)
with open("../db/db.csv", 'w', newline='') as csvfile:
    writer = csv.DictWriter(csvfile, fieldnames=["salle", "couleur", "prenom", "hasEntered", "nom", "registeredTimestamp", "enteredTimestamp", "leaveTimestamp", "externe", "id"])
    writer.writeheader()
    for key in fullDb:
        writer.writerow(key)
