class TenantMailer < ApplicationMailer
  default from: "noreply@hestia.local"

  def invitation_email(tenant, property = nil)
    @tenant = tenant
    @property = property
    @confirmation_url = edit_user_registration_url(host: "localhost:3000")
    mail(to: @tenant.email, subject: "Bienvenida a Hestia - Configurar tu cuenta")
  end

  def document_confirmation_email(occupant, property, document)
    @occupant = occupant
    @property = property
    @document = document
    @portal_url = portal_dashboard_url(host: "localhost:3000")
    mail(to: @occupant.email, subject: "Nuevo documento - #{@document.document_type&.name} - #{@property.address}")
  end
end
