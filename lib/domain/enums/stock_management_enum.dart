enum StockManagementEnum {
  fifo,
  lifo,
}

// Map to associate each enum value with its description
const stockManagementDescriptions = {
  StockManagementEnum.fifo: 'Primero en entrar, Primero en salir.',
  StockManagementEnum.lifo: 'Último en entrar, Primero en salir.',
};
