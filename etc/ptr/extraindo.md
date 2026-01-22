# Extraindo ponteiros
Na pasta `etc/Ponteiros` você encontrará alguns `.bat` numerados para serem executados na ordem indicada.
1. Instalar o Python 3.11 x86 junto do [pefile](https://pypi.org/project/pefile/) e [unlicense](https://github.com/ergrelet/unlicense) - **use esse `.bat` apenas na primeira vez!**
2. Faz *unpack* do Ragexe e salva na pasta como `unpacked_Ragexe.exe`
**Obs.: se o jogo foi instalado em outro local, abra o `.bat` num editor de texto e edite o caminho na linha a seguir**
	```batch
	SET TARGET_FOLDER=C:\Gravity\Ragnarok
	```
3. Busca pelos ponteiros usando o executável gerado na pasta - os ponteiros serão salvos no arquivo `ponteiros.txt` pronto para colocar no código. **Caso algum ponteiro não seja encontrado, será necessário utilizar ferramentas avançadas como o [IDA](https://hex-rays.com/ida-free) para encontrá-lo.**

## Usando o IDA
Caso a ferramenta na pasta não consiga encontrar algum ponteiro, será necessário recorrer a ferramentas como o IDA, comumente usado para este caso.

A seguir, uma lista de assinaturas/*array of bytes* que a ferramenta usa para buscar os endereços. Verifique no IDA se esses endereços realmente existem:
- **CRAG_CONNECTION_PTR**: `C7 05 ? ? ? ? ? ? ? ? C7 05 ? ? ? ? FF FF FF FF C6 05 ? ? ? ? 00`
- **CHECKSUM_FUN_ADDRESS**: `55 8B EC 83 EC 0C 53 8B 5D 14 56`
- **SEED_FUN_ADDRESS**: `FF 15 ? ? ? ? 8B 0D ? ? ? ? 6A 00 A3 ? ? ? ? E8 ? ? ? ? 66 31 07`
- **DOMAIN_ADDRESS_PTR**: `6A FF 68 81 00 00 00 50 E8 ? ? ? ? 83 C4 18 83 3D ? ? ? ? 0D`
- **T_ADDRESS_PTR**: `68 ? ? ? ? 50 6A FF 8D 85 ? ? ? ? 68 81 00 00 00 50 E8 ? ? ? ? 83 C4 14 E8 ? ? ? ? 8B 08 8B 51 04`

**Lembre-se: as assinaturas acima não são absolutas e podem mudar com atualizações do jogo!**