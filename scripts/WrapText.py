import os

def splitLines(file, maxChar):
    with open(file, 'r', encoding='utf-8') as input:
        text = input.read()
    
    flines = []
    actualLine = ""
    for word in text.split():
        if len(actualLine) + len(word) + 1 > maxChar:
            flines.append(actualLine.strip())
            actualLine = word + " "
        else:
            actualLine += word + " "
    if actualLine:  # Adiciona a última linha, se existir
        flines.append(actualLine.strip())
    
    # Sobrescreve o arquivo com as linhas formatadas
    with open(file, 'w', encoding='utf-8') as output:
        output.write('\r\n'.join(flines))
    print(f"O arquivo '{file}' foi atualizado com o texto formatado.")

def main():
    base = os.getcwd()
    fb = os.path.join(base, "scripts/secret/data.txt")
    splitLines(fb, 492)

if __name__ == "__main__":
    main()