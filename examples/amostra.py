"""Amostra sintética para conferir Vesper. Basta abrir; a execução é opcional."""

from dataclasses import dataclass


@dataclass
class Pedido:
    total: float
    pago: bool = False


def total_pago(pedidos: list[Pedido]) -> str:
    # Confira se os comentários continuam fáceis de ler.
    total = sum(pedido.total for pedido in pedidos if pedido.pago)
    return f"Total pago: {total:.2f}"


if __name__ == "__main__":
    pedidos = [Pedido(120.50, True), Pedido(30.00)]
    print(total_pago(pedidos))

# Compare a fonte: 0 O   1 l I   !=   ==   <=   >=   ->
# Este exemplo usa somente a biblioteca padrão; para executar, use Python 3.9+.
