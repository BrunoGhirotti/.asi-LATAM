import pefile
import struct
import sys
import os

SPLASH = r"""
#########################################################################################################
#########################################################################################################
####       ___              _   /\/           ___                                                    ####
####      / _ \___  _ __ __| | __ _  ___     / _ \_ __ ___   __ _ _ __ __ _ _ __ ___   __ _ ___      ####
####     / /_\/ _ \| '__/ _` |/ _` |/ _ \   / /_)/ '__/ _ \ / _` | '__/ _` | '_ ` _ \ / _` / __|     ####
####    / /_\\ (_) | | | (_| | (_| | (_) | / ___/| | | (_) | (_| | | | (_| | | | | | | (_| \__ \     ####
####    \____/\___/|_|  \__,_|\__,_|\___/  \/    |_|  \___/ \__, |_|  \__,_|_| |_| |_|\__,_|___/     ####
####                                                   |___/                                         ####
#########################################################################################################
#########################################################################################################
####                                Scanner de ponteiros para RO LATAM                               ####
####                               Desenvolvido por: Bruno Costa - 2026                              ####
####                                             v1.0.0                                              ####
#########################################################################################################
#########################################################################################################
"""

def parse_pattern(pattern):
    pat = []
    mask = []
    for b in pattern.split():
        if b in ("?", "??"):
            pat.append(0)
            mask.append("?")
        else:
            pat.append(int(b, 16))
            mask.append("x")
    return pat, mask


def find_pattern(data, pat, mask):
    plen = len(pat)
    for i in range(len(data) - plen):
        for j in range(plen):
            if mask[j] == "x" and data[i + j] != pat[j]:
                break
        else:
            return i
    return None


def file_offset_to_rva(section, file_offset):
    return section.VirtualAddress + (file_offset - section.PointerToRawData)


def find_function_prologue(pe, start_rva, max_back=0x300):
    start_off = pe.get_offset_from_rva(start_rva)
    data = pe.__data__

    for back in range(max_back):
        off = start_off - back
        if off < 0:
            break
        if data[off:off+3] == b"\x55\x8B\xEC":  # push ebp; mov ebp, esp
            return pe.get_rva_from_offset(off)

    return None


def get_import_va(pe, dll, name):
    for entry in pe.DIRECTORY_ENTRY_IMPORT:
        if entry.dll.decode(errors="ignore").lower() == dll.lower():
            for imp in entry.imports:
                if imp.name and imp.name.decode() == name:
                    return imp.address
    return None


def validate_cragconnection(pe, func_rva):
    off = pe.get_offset_from_rva(func_rva)
    data = pe.__data__[off:off + 0x500]

    # 1) String única
    if b"Failed to load Winsock library!" in data:
        return True

    # 2) Chamada a WSAStartup
    wsa_va = get_import_va(pe, "ws2_32.dll", "WSAStartup")
    if not wsa_va:
        return False

    image_base = pe.OPTIONAL_HEADER.ImageBase

    for i in range(len(data) - 5):
        if data[i] == 0xE8:  # call rel32
            rel = struct.unpack("<i", data[i+1:i+5])[0]
            target_rva = func_rva + i + 5 + rel
            if target_rva + image_base == wsa_va:
                return True

    return False


def scan_function(pe, pattern):
    pat, mask = parse_pattern(pattern)

    for section in pe.sections:
        data = section.get_data()
        found = find_pattern(data, pat, mask)
        if found is None:
            continue

        file_offset = section.PointerToRawData + found
        return file_offset_to_rva(section, file_offset)

    return None


def scan_call(pe, pattern):
    pat, mask = parse_pattern(pattern)
    tokens = pattern.split()
    e8_index = tokens.index("E8")

    for section in pe.sections:
        data = section.get_data()
        found = find_pattern(data, pat, mask)
        if found is None:
            continue

        file_offset = section.PointerToRawData + found
        rva = file_offset_to_rva(section, file_offset)

        call_file = file_offset + e8_index
        rel = struct.unpack("<i", pe.__data__[call_file+1:call_file+5])[0]

        return rva + e8_index + 5 + rel

    return None


def scan_ptr(pe, pattern, offset):
    pat, mask = parse_pattern(pattern)

    for section in pe.sections:
        data = section.get_data()
        found = find_pattern(data, pat, mask)
        if found is None:
            continue

        file_offset = section.PointerToRawData + found + offset
        return struct.unpack("<I", pe.__data__[file_offset:file_offset+4])[0]

    return None


def scan_cragconnection(pe, pattern):
    pat, mask = parse_pattern(pattern)

    print("Aoba... Scaneando CRagConnection...")

    for section in pe.sections:
        data = section.get_data()
        found = find_pattern(data, pat, mask)
        print(found)
        if found is None:
            print("Deu NONE")
            continue

        file_offset = section.PointerToRawData + found
        rva = file_offset_to_rva(section, file_offset)

        prologue = find_function_prologue(pe, rva)
        if not prologue:
            print("Deu NOT PROLOGUE")
            continue

        if validate_cragconnection(pe, prologue):
            return prologue

    return None


PATTERNS = {
    "CRAG_CONNECTION_PTR": {
        "pattern": "55 8B EC 6A FF 68 63 D7 EB 00 64 A1 00 00 00 00 50 83 EC 18 A1 7C 1E 19 01 33 C5 89 45 F0 53 56 57 50 8D 45 F4 64 A3 00 00 00 00 68 40 A1 51 01",
        "type": "ptr",
        "offset": 0
        ## 0xBE8760
    },
    "CHECKSUM_FUN_ADDRESS": {
        "pattern": "FF B6 84 00 00 00 FF B6 80 00 00 00 50 53 FF 75 0C E8 ?? ?? ?? ?? 8B 4E 74 83 C4 14 88 04 0B",
        "type": "call"
    },
    "SEED_FUN_ADDRESS": {
        "pattern": "8B 4E 74 8B 46 78 2B C1 50 51 E8 ?? ?? ?? ?? 83 C4 08 89 86 80 00 00 00 89 96 84 00 00 00",
        "type": "call"
    },
    "DOMAIN_ADDRESS_PTR": {
        "pattern": "6A FF 68 81 00 00 00 50 E8 ? ? ? ? 83 C4 18 83 3D ? ? ? ? 0D",
        "type": "ptr",
        "offset": -21
    },
    "T_ADDRESS_PTR": {
        "pattern": "68 ? ? ? ? 50 6A FF 8D 85 ? ? ? ? 68 81 00 00 00 50 E8 ? ? ? ? 83 C4 14 E8 ? ? ? ? 8B 08 8B 51 04",
        "type": "ptr",
        "offset": 1
    }
}

def main():
    if len(sys.argv) != 2:
        print("Uso: python scanner.py <executavel>")
        return

    exe = sys.argv[1]
    if not os.path.exists(exe):
        print("Arquivo não encontrado.")
        return

    pe = pefile.PE(exe, fast_load=False)
    image_base = pe.OPTIONAL_HEADER.ImageBase

    output_lines = []

    hasUnknown = False
    maxLenght = max(len(name) for name in PATTERNS.keys())

    for name, info in PATTERNS.items():
        skip = False
        if info["type"] == "crag":
            rva = scan_cragconnection(pe, info["pattern"])
            addr = rva + image_base if rva else None

        elif info["type"] == "call":
            rva = scan_call(pe, info["pattern"])
            addr = rva + image_base if rva else None

        elif info["type"] == "ptr":
            addr = scan_ptr(pe, info["pattern"], info["offset"])

        else:
            addr = None
        if addr is None:
            print(f"[-] {name}: DESCONHECIDO")
            hasUnknown = True
            skip = True
        else:
            print(f"[+] {name}: 0x{addr:08X}")
            line = f"#define {name}{' ' * (maxLenght - len(name) + 8)}0x{addr:08X}"

        if (not skip): output_lines.append(line)
    

    output_lines.append("\n// Não se preocupe com zeros à esquerda nos endereços! 0x000A = 0xA")

    if hasUnknown:
        warn = "Alguns endereços não foram encontrados! Busque os endereços desconhecidos usando o IDA."
        print(f"\n[!] {warn}")
        output_lines.append(f"// {warn}\n")

    # Nome do arquivo de saída
    out_name = "ponteiros.txt"

    with open(out_name, "w", encoding="utf-8") as f:
        f.write("\n".join(output_lines))

    print(f"\n[OK] Resultado salvo em: {out_name}")

if __name__ == "__main__":
    print(SPLASH)
    main()