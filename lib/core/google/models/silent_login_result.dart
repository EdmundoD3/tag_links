enum SilentLoginResult {
  success, // Todo bien
  noUser, // Nunca ha iniciado sesión (primera vez)
  expired, // Había sesión pero el token ya no sirve
  networkError, // No hay internet para verificar
  timeout, // Google tardó demasiado
  error
}