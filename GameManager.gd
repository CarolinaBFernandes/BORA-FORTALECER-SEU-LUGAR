extends Node

# Variável global declarada no topo do script
var sinal_credibilidade: int = 25

# Função que as portas e itens vão chamar para aumentar ou diminuir o sinal
func alterar_sinal(valor: int):
	sinal_credibilidade += valor
	sinal_credibilidade = clamp(sinal_credibilidade, 0, 100)
	print("Sinal de Credibilidade: ", sinal_credibilidade, "%")
