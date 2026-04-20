import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["templateSelect", "templateDetails"]

  connect() {
    this.toggleFields()
  }

  toggleFields() {
    const templateId = this.templateSelectTarget.value
    const fileField = document.getElementById("file-field")

    if (!templateId) {
      fileField.classList.remove("d-none")
      this.templateDetailsTarget.textContent = "Si seleccionas una plantilla HTML, el documento se renderizará desde esa plantilla con los datos del inmueble y del inquilino."
      return
    }

    fetch(`/document_templates/${templateId}.json`)
      .then(response => response.json())
      .then(data => {
        const templateType = data.document_type?.template_type || "html"

        if (templateType === "html") {
          fileField.classList.add("d-none")
          this.templateDetailsTarget.textContent = "Esta plantilla es HTML. El contenido final se verá al abrir el documento y se completará con sus variables dinámicas."
        } else {
          fileField.classList.remove("d-none")
          this.templateDetailsTarget.textContent = "Esta plantilla es de adjunto. Debes cargar el archivo final en este documento."
        }
      })
  }
}
