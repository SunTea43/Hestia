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
      fecha_inicio: ->(context) { context.contract&.start_date&.strftime("%d/%m/%Y") },
      fecha_fin: ->(context) { context.contract&.end_date&.strftime("%d/%m/%Y") },
      monto_deposito: ->(context) { context.contract&.deposit || 0 },
      monto_renta: ->(context) { context.contract&.rent_amount || context.property&.price }
    },
    propietario: {
      nombre_completo: ->(context) { context.company&.name || context.property&.company&.name },
      nit: ->(context) { context.company&.nit || context.property&.company&.nit },
      direccion: ->(context) { context.company&.address || context.property&.company&.address }
    },
    empresa: {
      nombre: ->(context) { context.company&.name || context.property&.company&.name },
      nit: ->(context) { context.company&.nit || context.property&.company&.nit },
      direccion: ->(context) { context.company&.address || context.property&.company&.address }
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
    resolver = VARIABLES.dig(category, variable)
    return "{{#{category}.#{variable}}}" unless resolver

    value = resolver.call(context)
    value || "{{#{category}.#{variable}}}"
  end
end
