class DocumentContext
  attr_accessor :property, :occupant, :contract, :company, :document

  def initialize(property:, occupant:, contract:, company:, document:)
    @property = property
    @occupant = occupant
    @contract = contract
    @company = company
    @document = document
  end
end
