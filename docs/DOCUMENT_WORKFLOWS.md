# Flujos Principales del Sistema de Gestión de Documentos

## Resumen

El sistema permite crear plantillas de documentos con variables dinámicas que se reemplazan con datos reales al generar documentos desde las plantillas. Soporta dos tipos de plantillas: plantillas HTML (editadas con TinyMCE) y plantillas de adjuntos (archivos subidos).

## Tipos de Plantillas

### 1. Plantillas HTML (Content Templates)
- **Descripción**: Plantillas con contenido HTML editado con TinyMCE
- **Uso**: Documentos que requieren formato personalizado con variables dinámicas
- **Ejemplos**: Contratos de arrendamiento, certificados, cartas
- **Campo en DocumentType**: `template_type = 'html'`
- **Características**:
  - Tienen campo `body` con contenido HTML
  - Contienen variables en formato `{{categoria.variable}}`
  - Se generan PDFs desde el HTML
  - No requieren archivo adjunto

### 2. Plantillas de Adjuntos (Attachment Templates)
- **Descripción**: Plantillas que consisten en archivos subidos
- **Uso**: Documentos preexistentes que solo se adjuntan
- **Ejemplos**: PDFs escaneados, imágenes, archivos de texto
- **Campo en DocumentType**: `template_type = 'attachment'`
- **Características**:
  - No tienen campo `body` (o está vacío)
  - Requieren archivo adjunto (PDF, TXT, XLSX, PNG, etc.)
  - Se descargan o visualizan directamente
  - No generan PDFs (ya son archivos)

## Flujo 1: Crear Plantilla HTML con Variables

### Paso 1: Crear DocumentType
```ruby
DocumentType.create!(
  name: 'Contrato de Arrendamiento',
  description: 'Plantilla para contratos de arrendamiento',
  template_type: 'html',  # Indica que es plantilla HTML
  variables: {
    inquilino: ['nombre_completo', 'cedula', 'email', 'telefono'],
    propiedad: ['direccion', 'area', 'precio_renta'],
    contrato: ['fecha_inicio', 'fecha_fin', 'monto_deposito'],
    propietario: ['nombre_completo', 'cedula']
  }
)
```

### Paso 2: Crear DocumentTemplate
```ruby
DocumentTemplate.create!(
  name: 'Contrato Estándar',
  description: 'Contrato de arrendamiento estándar',
  document_type_id: document_type.id,
  body: '
    <h1>CONTRATO DE ARRENDAMIENTO</h1>
    <p>Entre <strong>{{inquilino.nombre_completo}}</strong> (inquilino) y 
    <strong>{{propietario.nombre_completo}}</strong> (propietario)</p>
    <p>Dirección del inmueble: {{propiedad.direccion}}</p>
    <p>Área: {{propiedad.area}} m²</p>
    <p>Precio renta: ${{propiedad.precio_renta}}</p>
    <p>Fecha inicio: {{contrato.fecha_inicio}}</p>
    <p>Fecha fin: {{contrato.fecha_fin}}</p>
  '
)
```

### Paso 3: Editar Plantilla en UI
- Navegar a `/document_templates/new` o `/document_templates/:id/edit`
- Usar TinyMCE para editar el contenido HTML
- Insertar variables usando botones en la barra de herramientas
- Variables disponibles se muestran organizadas por categoría

## Flujo 2: Crear Documento desde Plantilla HTML

### Paso 1: Seleccionar Inmueble
- Navegar a `/properties/:id`
- Ver sección de documentos asociados

### Paso 2: Crear Nuevo Documento
- Click en "Nuevo Documento"
- Seleccionar plantilla (DocumentTemplate)
- El sistema pre-llena el contenido de la plantilla

### Paso 3: Reemplazo Automático de Variables
- El sistema detecta el inquilino y propietario asociados al inmueble
- Reemplaza las variables con datos reales:
  - `{{inquilino.nombre_completo}}` → "María García López"
  - `{{propiedad.direccion}}` → "Calle Falsa 123"
  - `{{contrato.fecha_inicio}}` → "2026-04-19"
- El usuario puede editar manualmente después del reemplazo

### Paso 4: Visualizar Documento
- Click en "Visualizar" en la vista de documentos
- Opciones disponibles:
  - **Visualizar**: Muestra el documento con variables reemplazadas
  - **Descargar PDF**: Genera PDF del documento
  - **Eliminar**: Elimina el documento (con confirmación)
  - **Firmar**: Placeholder para futura funcionalidad de firma electrónica

## Flujo 3: Crear Documento desde Plantilla de Adjuntos

### Paso 1: Crear DocumentType de Adjunto
```ruby
DocumentType.create!(
  name: 'Certificado de Tradición',
  description: 'Certificado escaneado',
  template_type: 'attachment'  # Indica que es plantilla de adjuntos
)
```

### Paso 2: Crear DocumentTemplate (opcional)
- Para plantillas de adjuntos, el DocumentTemplate puede ser solo un contenedor
- No requiere campo `body`

### Paso 3: Subir Archivo
- Navegar a vista de documentos del inmueble
- Click en "Nuevo Documento"
- Seleccionar tipo de documento (DocumentType de adjunto)
- Subir archivo (PDF, TXT, XLSX, PNG, etc.)

### Paso 4: Visualizar Documento
- Click en "Visualizar"
- Opciones disponibles:
  - **Visualizar**: Muestra el archivo adjunto
  - **Descargar**: Descarga el archivo original
  - **Eliminar**: Elimina el documento (con confirmación)
  - **Firmar**: Placeholder para futura funcionalidad de firma electrónica

## Sistema de Variables

### Estructura de Variables
Las variables están organizadas por categorías para facilitar su uso:

```ruby
# Ubicación: app/services/document_variable_resolver.rb
class DocumentVariableResolver
  VARIABLES = {
    inquilino: {
      nombre_completo: ->(context) { context.occupant&.name },
      cedula: ->(context) { context.occupant&.document_number },
      email: ->(context) { context.occupant&.email },
      telefono: ->(context) { context.occupant&.phone }
    },
    propiedad: {
      direccion: ->(context) { context.property&.address },
      area: ->(context) { context.property&.area },
      precio_renta: ->(context) { context.property&.price },
      tipo: ->(context) { context.property&.property_type }
    },
    contrato: {
      fecha_inicio: ->(context) { context.contract&.start_date&.strftime('%d/%m/%Y') },
      fecha_fin: ->(context) { context.contract&.end_date&.strftime('%d/%m/%Y') },
      monto_deposito: ->(context) { context.contract&.deposit || 0 },
      monto_renta: ->(context) { context.contract&.rent_amount || context.property&.price }
    },
    propietario: {
      nombre_completo: ->(context) { context.property&.company&.name },
      nit: ->(context) { context.property&.company&.nit },
      direccion: ->(context) { context.property&.company&.address }
    },
    empresa: {
      nombre: ->(context) { context.property&.company&.name },
      nit: ->(context) { context.property&.company&.nit },
      direccion: ->(context) { context.property&.company&.address }
    }
  }.freeze
end
```

### Sintaxis de Variables
- Formato: `{{categoria.variable}}`
- Ejemplos:
  - `{{inquilino.nombre_completo}}`
  - `{{propiedad.direccion}}`
  - `{{contrato.fecha_inicio}}`
  - `{{propietario.nombre_completo}}`

### Agregar Nuevas Variables
Para agregar una nueva variable:

1. Abrir `app/services/document_variable_resolver.rb`
2. Agregar la variable a la categoría correspondiente:
```ruby
inquilino: {
  nombre_completo: ->(context) { context.occupant&.name },
  cedula: ->(context) { context.occupant&.document_number },
  email: ->(context) { context.occupant&.email },
  telefono: ->(context) { context.occupant&.phone },
  direccion: ->(context) { context.occupant&.address }  # Nueva variable
}
```

3. Actualizar el DocumentType correspondiente si es necesario:
```ruby
DocumentType.find_by(name: 'Contrato de Arrendamiento').update(
  variables: {
    inquilino: ['nombre_completo', 'cedula', 'email', 'telefono', 'direccion']
  }
)
```

## Contexto de Variables

El contexto para resolver variables incluye:

```ruby
class DocumentContext
  attr_accessor :property,  # Inmueble asociado
                :occupant,  # Inquilino asociado
                :contract,  # Contrato asociado
                :company,   # Empresa gestora
                :document   # Documento actual
end
```

## Generación de PDF

### Para Plantillas HTML
1. El documento HTML se genera con variables reemplazadas
2. Se usa una librería de generación de PDF (ej: Grover, Wicked PDF, Puppeteer)
3. El PDF se genera desde el HTML renderizado
4. El PDF se puede descargar o visualizar en el navegador

### Para Plantillas de Adjuntos
- No se genera PDF (el archivo ya existe)
- Se descarga o visualiza el archivo original

## Integración con TinyMCE

### Botones para Insertar Variables
TinyMCE tiene una barra de herramientas personalizada con botones para insertar variables:

```javascript
// app/javascript/controllers/tinymce_controller.js
tinymce.init({
  toolbar: 'insertInquilinoVariables insertPropiedadVariables insertContratoVariables',
  setup: function(editor) {
    editor.ui.registry.addButton('insertInquilinoVariables', {
      text: 'Variables Inquilino',
      onAction: function() {
        // Muestra menú desplegable con variables de inquilino
      }
    });
  }
});
```

### Variables Disponibles por Categoría
- **Inquilino**: nombre_completo, cedula, email, telefono, direccion
- **Propiedad**: direccion, area, precio_renta, tipo
- **Contrato**: fecha_inicio, fecha_fin, monto_deposito, monto_renta
- **Propietario**: nombre_completo, nit, direccion
- **Empresa**: nombre, nit, direccion

## Acciones en Vista de Documentos

### Acciones Disponibles
En la vista de documentos asociados a un inmueble (`/properties/:id`), cada documento tiene:

1. **Visualizar**
   - Para plantillas HTML: Muestra el documento con variables reemplazadas
   - Para plantillas de adjuntos: Muestra el archivo adjunto
   - URL: `/documents/:id`

2. **Descargar PDF**
   - Para plantillas HTML: Genera y descarga PDF
   - Para plantillas de adjuntos: Descarga el archivo original
   - URL: `/documents/:id/download`

3. **Eliminar**
   - Elimina el documento (con confirmación)
   - URL: `/documents/:id` (DELETE request)

4. **Firmar** (placeholder)
   - Futura funcionalidad de firma electrónica
   - Actualmente muestra mensaje "Funcionalidad de firma en desarrollo"
   - URL: `/documents/:id/sign`

## Consideraciones de Seguridad

- Validación de tipos de archivos permitidos para adjuntos
- Sanitización de HTML para prevenir XSS
- Autorización con Pundit para todas las acciones
- Validación de variables para prevenir inyección de código
- Logs de auditoría para acciones de documentos

## Futuras Mejoras

- Firma electrónica de documentos
- Historial de versiones de documentos
- Envío de documentos por email
- Notificaciones de documentos pendientes
- Búsqueda avanzada de documentos
- Etiquetas y categorías adicionales
- Plantillas compartidas entre empresas
