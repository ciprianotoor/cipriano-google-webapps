# Google Webapps para Omarchy

Widget de barra con un menú automático de webapps instaladas en Chromium.

- Clic izquierdo: abre el menú de webapps detectadas.
- Lee los archivos `.desktop` de `~/.local/share/applications` que Chromium genera al instalar una webapp.
- Cada acceso se abre con `gtk-launch`, conservando el perfil, icono y configuración de Chromium.
- Si no encuentra webapps, muestra un aviso y no inventa accesos fijos.
- El listado se vuelve a escanear cada vez que se abre el menú.
- El menú se adapta automáticamente al número de webapps y usa una cuadrícula compacta.
- Clic derecho sobre una webapp abre un submenú para quitar su acceso; el archivo `.desktop` se mueve a la papelera.

Requiere que el ejecutable `chromium` esté disponible en `PATH`.
