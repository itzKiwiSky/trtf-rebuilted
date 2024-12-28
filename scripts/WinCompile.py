from MakeLove import makeZip
import zipfile
import wget
import os
import shutil

def joinFiles(f1, f2, out):
    with open(f1, "rb") as fexe, open(f2, "rb") as flove, open(out, "wb") as fout:
        fout.write(fexe.read())
        fout.write(flove.read())

def mvFile(o, d):
    try:
        shutil.move(o, d)
    except FileNotFoundError:
        print(f"[ERROR]: file '{o}' not found.")
    except Exception as e:
        print(f"[ERROR] while moving file: {e}")

def main():
    ig = [
        "./crashlog.txt",
        "./build.lua",
        "./boot.cmd",
        "./make.cmd",
        "./README.md",
        "./.gitattributes",
        "./.gitignore",
        "./.commitid",
        "./gjpromo",
        "./export",
        "./static",
        "./scripts",
        "./.git",
        "./mapping_data.b64"
    ]
    
    base = os.getcwd()
    fp = os.path.join(base, "export/love-11-5.zip")
    fb = os.path.join(base, "export")

    if os.path.exists(os.path.join(fb, "love")) and os.path.isdir(os.path.join(fb, "love")):
        shutil.rmtree(os.path.join(fb, "love"))
    
    # download love from the last release
    url = "https://github.com/love2d/love/releases/download/11.5/love-11.5-win64.zip"

    wget.download(url, fp)

    # extract love
    with zipfile.ZipFile(fp, 'r') as lovezip:
        lovezip.extractall(fb)

    # clean mess and rename the folder
    os.remove(fp)
    os.rename(os.path.join(fb, "love-11.5-win64"), os.path.join(fb, "love"))

    # create the love
    makeZip("./", "./export/feddy.love", ig)

    # move the file to folder
    mvFile(os.path.join(fb, "feddy.love"), os.path.join(fb, "love"))

    # fuse
    joinFiles(os.path.join(fb, "love/love.exe"), os.path.join(fb, "love/feddy.love"), os.path.join(fb, "love/game.exe"))

if __name__ == "__main__":
    main()