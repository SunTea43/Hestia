class DocumentVariableResolver
  VARIABLES = {
    tenant: {
      full_name: ->(context) { context.occupant&.name },
      document_number: ->(context) { context.occupant&.document_number },
      email: ->(context) { context.occupant&.email },
      phone: ->(context) { context.occupant&.phone }
    },
    property: {
      address: ->(context) { context.property&.address },
      area: ->(context) { context.property&.area },
      rent_price: ->(context) { context.property&.price },
      type: ->(context) { context.property&.property_type }
    },
    contract: {
      start_date: ->(context) { context.contract&.start_date&.strftime("%d/%m/%Y") },
      end_date: ->(context) { context.contract&.end_date&.strftime("%d/%m/%Y") },
      deposit_amount: ->(context) { context.contract&.deposit || 0 },
      rent_amount: ->(context) { context.contract&.rent_amount || context.property&.price }
    },
    owner: {
      full_name: ->(context) { context.company&.name || context.property&.company&.name },
      nit: ->(context) { context.company&.nit || context.property&.company&.nit },
      address: ->(context) { context.company&.address || context.property&.company&.address }
    },
    company: {
      name: ->(context) { context.company&.name || context.property&.company&.name },
      nit: ->(context) { context.company&.nit || context.property&.company&.nit },
      address: ->(context) { context.company&.address || context.property&.company&.address }
    }
  }.freeze

  CATEGORY_ALIASES = {
    tenant: %w[tenant inquilino occupant ocupante arrendatario],
    property: %w[property propiedad inmueble],
    contract: %w[contract contrato],
    owner: %w[owner propietario mandante],
    company: %w[company empresa]
  }.freeze

  VARIABLE_ALIASES = {
    tenant: {
      full_name: %w[full_name nombre_completo name nombre],
      document_number: %w[document_number cedula numero_documento],
      email: %w[email correo],
      phone: %w[phone telefono celular]
    },
    property: {
      address: %w[address direccion],
      area: %w[area],
      rent_price: %w[rent_price precio_renta canon precio],
      type: %w[type tipo property_type tipo_propiedad]
    },
    contract: {
      start_date: %w[start_date fecha_inicio],
      end_date: %w[end_date fecha_fin],
      deposit_amount: %w[deposit_amount monto_deposito deposito],
      rent_amount: %w[rent_amount monto_renta canon]
    },
    owner: {
      full_name: %w[full_name nombre_completo name nombre],
      nit: %w[nit],
      address: %w[address direccion]
    },
    company: {
      name: %w[name nombre],
      nit: %w[nit],
      address: %w[address direccion]
    }
  }.freeze

  attr_reader :context

  def initialize(context)
    @context = context
  end

  def resolve(template_body)
    return template_body unless template_body

    template_body.gsub(/\{\{(\w+)\.(\w+)\}\}/) do |_match|
      category = Regexp.last_match(1)
      variable = Regexp.last_match(2)
      resolve_variable(category, variable)
    end
  end

  def self.available_variables
    VARIABLES
  end

  def self.available_categories
    VARIABLES.keys
  end

  private

  def resolve_variable(category, variable)
    canonical_category = canonical_category_for(category)
    canonical_variable = canonical_variable_for(canonical_category, variable)
    resolver = VARIABLES.dig(canonical_category, canonical_variable)
    return "{{#{category}.#{variable}}}" unless resolver

    value = resolver.call(context)
    value || "{{#{category}.#{variable}}}"
  end

  def canonical_category_for(category)
    CATEGORY_ALIASES.find do |_canonical_category, aliases|
      aliases.include?(category.to_s)
    end&.first&.to_sym || category.to_sym
  end

  def canonical_variable_for(category, variable)
    aliases = VARIABLE_ALIASES[category] || {}

    aliases.find do |_canonical_variable, known_aliases|
      known_aliases.include?(variable.to_s)
    end&.first&.to_sym || variable.to_sym
  end
end
