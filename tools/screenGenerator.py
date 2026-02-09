pref = 0b00100100
x = 6
y = 29

word = "bauwen,teun,mattias"
word = word.upper()

def char_to_hex(char: str) -> str:
    if len(char) != 1:
        raise ValueError("Input must be a single character")

    # Special characters
    if char == " ":
        return "A0"
    if char == ",":
        return "AC"

    # Uppercase letters
    if 'A' <= char <= 'Z':
        value = 0xC1 + (ord(char) - ord('A'))
        return f"{value:02X}"

    # Lowercase letters
    if 'a' <= char <= 'z':
        value = 0xE1 + (ord(char) - ord('a'))
        return f"{value:02X}"


totalstring = ""
for i in word:
    if i != 'a':
        end_X = pref + (y>>3)
        end_Y = x + ((y & 0b111)<<5) 

        xstring     = str(hex(end_X)).upper()
        ystring     = str(hex(end_Y)).upper()

        tilestring = (char_to_hex(i))
        sting = f"\t;{i}\n\tldx #${xstring[-2:]}\n\tldy #${ystring[-2:]}\n\tlda #${tilestring[-2:]}\n\tjsr push_background_buffer\n\n"
        totalstring += sting
    x += 1

print(f"ldx #${xstring[-2:]}")
print(f"ldy #${ystring[-2:]}")


import pyperclip
pyperclip.copy(totalstring)
spam = pyperclip.paste()