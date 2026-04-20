import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["templateSelect", "bodyField", "propertySelect", "occupantSelect"]
  static values = { templateBody: String }

  loadTemplate(event) {
    const templateId = event.target.value
    if (!templateId) return

    fetch(`/document_templates/${templateId}.json`)
      .then(response => response.json())
      .then(data => {
        this.bodyFieldTarget.value = data.body
        this.templateBodyValue = data.body
        this.interpolateVariables()
      })
  }

  toggleFields(event) {
    const templateId = event.target.value
    const fileField = document.getElementById('file-field')
    const bodyField = document.getElementById('body-field')

    if (!templateId) {
      fileField.classList.remove('d-none')
      bodyField.classList.remove('d-none')
      return
    }

    fetch(`/document_templates/${templateId}.json`)
      .then(response => response.json())
      .then(data => {
        const templateType = data.document_type?.template_type || 'html'

        if (templateType === 'html') {
          fileField.classList.add('d-none')
          bodyField.classList.remove('d-none')
        } else if (templateType === 'attachment') {
          fileField.classList.remove('d-none')
          bodyField.classList.add('d-none')
        } else {
          fileField.classList.remove('d-none')
          bodyField.classList.remove('d-none')
        }
      })
  }

  interpolateVariables() {
    let body = this.bodyFieldTarget.value

    // Get property and occupant data if available
    const propertyId = this.propertySelectTarget.value
    const occupantId = this.occupantSelectTarget.value

    if (propertyId) {
      fetch(`/properties/${propertyId}.json`)
        .then(response => response.json())
        .then(data => {
          body = body.replace(/\{\{property\.address\}\}/g, data.address || '')
          body = body.replace(/\{\{property\.area\}\}/g, data.area || '')
          body = body.replace(/\{\{property\.price\}\}/g, data.price || '')
          body = body.replace(/\{\{property\.property_type\}\}/g, data.property_type || '')
          body = body.replace(/\{\{property\.description\}\}/g, data.description || '')
          this.bodyFieldTarget.value = body
        })
    }

    if (occupantId) {
      fetch(`/occupants/${occupantId}.json`)
        .then(response => response.json())
        .then(data => {
          body = body.replace(/\{\{occupant\.name\}\}/g, data.name || '')
          body = body.replace(/\{\{occupant\.email\}\}/g, data.email || '')
          body = body.replace(/\{\{occupant\.phone\}\}/g, data.phone || '')
          body = body.replace(/\{\{occupant\.document_number\}\}/g, data.document_number || '')
          this.bodyFieldTarget.value = body
        })
    }
  }

  propertyChanged() {
    this.interpolateVariables()
  }

  occupantChanged() {
    this.interpolateVariables()
  }
}
