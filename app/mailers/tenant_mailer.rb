class TenantMailer < ApplicationMailer
  default from: "noreply@hestia.local"

  def invitation_email(tenant, property = nil)
    @tenant = tenant
    @property = property
    @confirmation_url = edit_user_registration_url(host: "localhost:3000")
    mail(to: @tenant.email, subject: "Bienvenida a Hestia - Configurar tu cuenta")
  end

  def contract_confirmation_email(tenant, property, contract)
    @tenant = tenant
    @property = property
    @contract = contract
    @portal_url = portal_dashboard_url(host: "localhost:3000")
    mail(to: @tenant.email, subject: "Nuevo contrato de arrendamiento - #{@property.address}")
  end
end
