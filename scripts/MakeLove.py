import zipfile
import os
from tqdm import tqdm

def makeZip(base, name, ignore = []):
    pitems = []
    for root, folders, files in os.walk(base):
        folders[:] = [f for f in folders if os.path.join(root, f) not in ignore]

        for folder in folders:
            cpath = os.path.join(root, folder)
            rpath = os.path.relpath(cpath, base)
            if cpath not in ignore:
                pitems.append(cpath + "/")

        # Adiciona os arquivos
        for file in files:
            cpath = os.path.join(root, file)
            rpath = os.path.relpath(cpath, base)
            if cpath not in ignore:
                pitems.append(cpath)

    with zipfile.ZipFile(name, "w", zipfile.ZIP_DEFLATED) as zip:
        with tqdm(total = len(pitems), desc = "Making love file...", unit = "item") as progressbar:
            for i in pitems:
                rpath = os.path.relpath(i, base)
                if i.endswith("/"):
                    zip.write(i, rpath)
                else:
                    zip.write(i, rpath)
                progressbar.update(1)