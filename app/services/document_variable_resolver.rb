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
