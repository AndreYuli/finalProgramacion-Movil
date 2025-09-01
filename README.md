
# Cambio - Conversor de Moneda

Aplicación móvil en Flutter que permite al usuario ingresar un valor en pesos colombianos (COP) y convertirlo a diferentes divisas (USD, EUR, BRL) seleccionadas. Soporta localización en español e inglés.

## Arquitectura

- **Flutter**: Framework principal para la interfaz y lógica.
- **MVVM**: Separación en:
  - **View**: `conversion_page.dart` (interfaz y lógica de usuario)
  - **ViewModel**: `conversion_viewmodel.dart` (gestión de estado y lógica de conversión)
  - **Repository**: `currency_repository.dart` (acceso a API de tasas de cambio)
- **Internacionalización**: Archivos en `lib/l10n/` para soporte multilenguaje.
- **Persistencia local**: Uso de `shared_preferences` para guardar idioma seleccionado.
- **Conectividad**: Verificación de conexión a internet con `connectivity_plus`.

## Herramientas de desarrollo

- **Flutter SDK >= 3.7.2**
- **Dart**
- **Paquetes principales**:
  - `http`
  - `shared_preferences`
  - `connectivity_plus`
  - `intl`
  - `flutter_localizations`
- **IDE recomendado**: VS Code, Android Studio

## Ejecución del proyecto

1. **Instala Flutter**  
	[Guía oficial](https://docs.flutter.dev/get-started/install)

2. **Instala dependencias**  
	Abre una terminal en la raíz del proyecto y ejecuta:
	```
	flutter pub get
	```

3. **Ejecuta la app**  
	Conecta un dispositivo o inicia un emulador, luego ejecuta:
	```
	flutter run
	```

4. **Configuración adicional**  
	- La app usa una API key para [ExchangeRate API](https://www.exchangerate-api.com/).  
	- Puedes cambiar la clave en `lib/currency_repository.dart` si es necesario.

## Estructura principal

```
lib/
  main.dart                // Entrada principal
  conversion_page.dart     // Vista principal
  conversion_viewmodel.dart// Lógica de conversión
  currency_repository.dart // Acceso a API de tasas
  l10n/                    // Archivos de localización
```
>>>>>>> 4ec9655e978ce409e31ba0eb489e0ced24043019
